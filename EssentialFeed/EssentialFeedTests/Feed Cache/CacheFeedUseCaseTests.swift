//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/12/22.
//

import Foundation
import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
    
    func completeDeletion(with error: NSError) {
        
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeletesCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestsInsertOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        trackMemoryLeaks(instance: store, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any desc", location: "any loc", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any domain", code: 100)
    }
}
