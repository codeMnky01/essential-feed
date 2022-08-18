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
        let decoder = JSONDecoder()
        
        guard
            let data = try? Data(contentsOf: cacheStoreURL),
            let cache = try? decoder.decode(Cache.self, from: data)
        else {
            completion(.empty)
            return
        }
        
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let codableFeed = feed.map(CodableFeedImage.init)
        let cache = Cache(feed: codableFeed, timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: cacheStoreURL)
        
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: cacheStoreURL())
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? FileManager.default.removeItem(at: cacheStoreURL())
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected same results, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertionToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for completion")
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected nil, got \(insertionError!)")
            
            sut.retrieve { retrievingResult in
                switch retrievingResult {
                case let .found(feed: foundFeed, timestamp: foundTimestamp):
                    XCTAssertEqual(feed, foundFeed)
                    XCTAssertEqual(timestamp, foundTimestamp)
                    
                default:
                    XCTFail("Expected \(feed) and \(timestamp), got \(retrievingResult)")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let store = CodableFeedStore(cacheStoreURL: cacheStoreURL())
        trackMemoryLeaks(instance: store, file: file, line: line)
        return store
    }
    
    private func cacheStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("imagefeed.store")
    }
}
