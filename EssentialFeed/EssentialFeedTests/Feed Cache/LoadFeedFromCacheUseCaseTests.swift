//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/16/22.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotDeletesCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_messagesStoreUponLoad() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()
        
        let exp = expectation(description: "Wait for completion")
        var receivedError: Error?
        sut.load() { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected \(expectedError), got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrieval(with: expectedError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(expectedError, receivedError as? NSError)
    }
    
    func test_load_deliversEmtpyImageFeedOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        var imageFeed = [FeedImage]()
        sut.load() { result in
            switch result {
            case let .success(images):
                imageFeed = images
            default:
                XCTFail("Expected empty feed, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrievalWithEmptyCache()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(imageFeed.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping (() -> Date) = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackMemoryLeaks(instance: store, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, store)
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "any domain", code: 100)
    }
}
