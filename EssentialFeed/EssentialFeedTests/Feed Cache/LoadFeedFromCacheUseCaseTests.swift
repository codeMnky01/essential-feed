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
        
        expect(sut, completeWith: .failure(expectedError), when: {
            store.completeRetrieval(with: expectedError)
        })
    }
    
    func test_load_deliversEmtpyImageFeedOnEmptyCache() {
        let (sut, store) = makeSUT()
        let imageFeed = [FeedImage]()
    
        expect(sut, completeWith: .success(imageFeed), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping (() -> Date) = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackMemoryLeaks(instance: store, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, completeWith expectedResult: LoadFeedResult, when action: @escaping () -> Void) {
        let exp = expectation(description: "Wait for completion")
        
        sut.load() { receivedResult in
            switch (expectedResult, receivedResult) {
                
            case (let .success(expectedImages), let .success(receivedImages)):
                XCTAssertEqual(expectedImages, receivedImages)
                
            case (let .failure(expectedError), let .failure(receivedError)):
                XCTAssertEqual(expectedError as NSError, receivedError as NSError)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "any domain", code: 100)
    }
}
