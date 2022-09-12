//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 9/12/22.
//

import XCTest
import EssentialFeed

class CacheFeedImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreAfterInitialization() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_saveImageDataForURL_requestsImageDataSaveForURL() {
        let (sut, store) = makeSUT()
        let imageData = anyData()
        let url = anyURL()
        
        sut.save(image: imageData, for: url) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(data: imageData, for: url)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping (() -> Date) = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackMemoryLeaks(instance: store, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, store)
    }
}
