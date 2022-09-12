//
//  LoadFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 9/11/22.
//

import XCTest
import EssentialFeed

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
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
            store.completeRetrievalWithError(anyNSError())
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorWhenStoreNotFoundImageData() {
        let (sut, store) = makeSUT()
        
        expect(sut, toReceive: failure(.notFound)) {
            store.completeRetrievalWith(nil)
        }
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let imageData = anyData()
        
        expect(sut, toReceive: .success(imageData)) {
            store.completeRetrievalWith(imageData)
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
        
        store.completeRetrievalWith(.none)
        store.completeRetrievalWith(imageData)
        store.completeRetrievalWithError(anyNSError())
        
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
        
        store.completeRetrievalWith(.none)
        store.completeRetrievalWith(imageData)
        store.completeRetrievalWithError(anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_saveImageDataForURL_requestsImageDataSaveForURL() {
        let (sut, store) = makeSUT()
        let imageData = anyData()
        let url = anyURL()
        
        sut.save(image: imageData, for: url) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(data: imageData, for: url)])
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
    
    private func failure(_ error: LocalFeedImageDataLoader.LoadError) -> FeedImageDataLoader.Result {
        .failure(error)
    }
    
    private class StoreSpy: FeedImageDataStore {
        private(set) var messages = [Message]()
        private var retrieveCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
        private var saveCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
        
        enum Message: Equatable {
            case insert(data: Data, for: URL)
            case retrieve(dataFor: URL)
        }
        
        func insert(data: Data, forURL url: URL, completion: @escaping (InsertionResult) -> Void) {
            messages.append(.insert(data: data, for: url))
            saveCompletions.append(completion)
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            messages.append(.retrieve(dataFor: url))
            retrieveCompletions.append(completion)
        }
        
        func completeRetrievalWithError(_ error: Error, at index: Int = 0) {
            retrieveCompletions[index](.failure(error))
        }
        
        func completeRetrievalWith(_ data: Data?, at index: Int = 0) {
            retrieveCompletions[index](.success(data))
        }
    }
}
