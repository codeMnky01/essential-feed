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
    
    func test_saveImageDataForURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toReceive: failure(.failed)) {
            store.completeInsertionWithError(anyNSError())
        }
    }
    
    func test_saveImageDataForURL_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toReceive: .success(())) {
            store.completeInsertionWithSuccess()
        }
    }
    
    func test_saveImageDataForURL_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        let imageData = anyData()
        let url = anyURL()
        
        var receivedResults = [LocalFeedImageDataLoader.SaveResult]()
        _ = sut?.save(image: imageData, for: url) { result in
            receivedResults.append(result)
        }
        
        sut = nil
        
        store.completeInsertionWithError(anyNSError())
        store.completeInsertionWithSuccess()
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping (() -> Date) = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackMemoryLeaks(instance: store, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toReceive expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void,  file: StaticString = #filePath, line: UInt = #line) {
        let url = anyURL()
        let imageData = anyData()
        
        let exp = expectation(description: "Wait for completion")
        sut.save(image: imageData, for: url) { receivedResult in
            switch (expectedResult, receivedResult) {
                
            case (.success, .success):
                break
                
            case (let .failure(expectedError), let .failure(receivedError)):
                XCTAssertEqual(expectedError as NSError, receivedError as NSError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: LocalFeedImageDataLoader.SaveError) -> LocalFeedImageDataLoader.SaveResult {
        .failure(error)
    }
}
