//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/18/22.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
    
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
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
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
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = cachesDirectoryURL()
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let error = insert(feed: feed, timestamp: timestamp, to: sut)
        XCTAssertNotNil(error, "Expected cache insertion to fail with an error")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "/a-invalid.url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        insert(feed: uniqueImageFeed().local, timestamp: Date(), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let sut = makeSUT(storeURL: noDeletePermissionURL())
        
        let error = deleteCache(sut)
        XCTAssertNotNil(error, "Expected cache deletion to fail with an error")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let invalidStoreURL = URL(string: "/a-invalid.url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        deleteCache(sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        assertThatStoreSideEffectsRunSerially(on: sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let store = CodableFeedStore(cacheStoreURL: storeURL ?? testSpecificStoreURL())
        trackMemoryLeaks(instance: store, file: file, line: line)
        return store
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectoryURL().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectoryURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func noDeletePermissionURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
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
