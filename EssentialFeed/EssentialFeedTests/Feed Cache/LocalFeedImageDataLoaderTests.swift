//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 9/11/22.
//

import XCTest
import EssentialFeed

class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreAfterInitialization() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toReceive: failure(.failed)) {
            store.completeWithError(anyNSError())
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorWhenStoreNotFoundImageData() {
        let (sut, store) = makeSUT()
        
        expect(sut, toReceive: failure(.notFound)) {
            store.completeWith(nil)
        }
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let imageData = anyData()
        
        expect(sut, toReceive: .success(imageData)) {
            store.completeWith(imageData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancelTask() {
        let (sut, store) = makeSUT()
        let imageData = anyData()
        
        var receivedResults = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { result in
            receivedResults.append(result)
        }
        task.cancel()
        
        store.completeWith(.none)
        store.completeWith(imageData)
        store.completeWithError(anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let store = StoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        let imageData = anyData()
        
        var receivedResults = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { result in
            receivedResults.append(result)
        }
        
        sut = nil
        
        store.completeWith(.none)
        store.completeWith(imageData)
        store.completeWithError(anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping (() -> Date) = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackMemoryLeaks(instance: store, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toReceive expectedResult: FeedImageDataLoader.Result, when action: () -> Void,  file: StaticString = #filePath, line: UInt = #line) {
        let url = anyURL()
        
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: url) { receivedResult in
            switch (expectedResult, receivedResult) {
                
            case (let .success(expectedData), let .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
                
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
    
    private func failure(_ error: LocalFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
    }
    
    private class StoreSpy: FeedImageDataStore {
        private(set) var messages = [Message]()
        private var retrievalCompletions = [(FeedImageDataStore.Result) -> Void]()
        
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            messages.append(.retrieve(dataFor: url))
            retrievalCompletions.append(completion)
        }
        
        func completeWithError(_ error: Error, at index: Int = 0) {
            retrievalCompletions[index](.failure(error))
        }
        
        func completeWith(_ data: Data?, at index: Int = 0) {
            retrievalCompletions[index](.success(data))
        }
    }
}
