//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/18/22.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map(\.local)
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ localFeedImage: LocalFeedImage) {
            self.id = localFeedImage.id
            self.description = localFeedImage.description
            self.location = localFeedImage.location
            self.url = localFeedImage.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let cacheStoreURL: URL
    
    init(cacheStoreURL: URL) {
        self.cacheStoreURL = cacheStoreURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: cacheStoreURL) else {
            completion(.empty)
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch(let error) {
            completion(.failure(error))
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let codableFeed = feed.map(CodableFeedImage.init)
            let cache = Cache(feed: codableFeed, timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: cacheStoreURL)
            
            completion(nil)
        } catch(let error) {
            completion(error)
        }
    }
    
    func delete(completion: @escaping FeedStore.DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: cacheStoreURL.path) else {
            completion(nil)
            return
        }
        
        do {
            try FileManager.default.removeItem(at: cacheStoreURL)
            completion(nil)
        } catch(let error) {
            completion(error)
        }
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(feed: feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(feed: feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid date".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid date".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstError = insert(feed: uniqueImageFeed().local, timestamp: Date(), to: sut)
        XCTAssertNil(firstError, "Expected nil, got \(firstError!)")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestError = insert(feed: latestFeed, timestamp: latestTimestamp, to: sut)
        XCTAssertNil(latestError, "Expected nil, got \(latestError!)")
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversFailureOnInsertionError() {
        let invalidStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let error = insert(feed: feed, timestamp: timestamp, to: sut)
        XCTAssertNotNil(error, "Expected cache insertion to fail with an error")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let error = deleteCache(sut)
        XCTAssertNil(error, "Expected to complete deletion without an error")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        insert(feed: uniqueImageFeed().local, timestamp: Date(), to: sut)
        
        let error = deleteCache(sut)
        XCTAssertNil(error, "Expected to complete deletion without an error")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let invalidStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        let error = deleteCache(sut)
        XCTAssertNotNil(error, "Expected cache deletion to fail with an error")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let store = CodableFeedStore(cacheStoreURL: storeURL ?? testSpecificStoreURL())
        trackMemoryLeaks(instance: store, file: file, line: line)
        return store
    }
    
    @discardableResult
    private func insert(feed: [LocalFeedImage], timestamp: Date, to sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var error: Error?
        sut.insert(feed, timestamp: timestamp) { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return error
    }
    
    @discardableResult
    private func deleteCache(_ sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var error: Error?
        sut.delete { deletionError in
            error = deletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return error
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: CacheRetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: CacheRetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for completion")
        sut.retrieve { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.found(feed: expectedFeed, timestamp: expectedTimestamp),
                      .found(feed: receivedFeed, timestamp: receivedTimestamp)):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, receivedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) results, got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
