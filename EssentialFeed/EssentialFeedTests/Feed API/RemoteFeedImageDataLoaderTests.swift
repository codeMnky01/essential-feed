//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by Andrey on 9/9/22.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: anyURL()) {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURL_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: anyURL()) {_ in }
        sut.loadImageData(from: anyURL()) {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let error = anyNSError()
        
        expect(sut, toReceive: .failure(error)) {
            client.complete(withError: error)
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let statusCodes = [100, 150, 199, 201, 300, 404]
        
        for (index, statusCode) in statusCodes.enumerated() {
            expect(sut, toReceive: failure(.invalidData)) {
                client.complete(withStatusCode: statusCode, data: anyData, at: index)
            }
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toReceive: failure(.invalidData)) {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }
    
    func test_loadImageDataFromURL_deliversNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let data = anyData
        
        expect(sut, toReceive: .success(data)) {
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: Data())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in  }
        XCTAssertEqual(client.canceledURLs, [])
        
        task.cancel()
        XCTAssertEqual(client.canceledURLs, [url])
    }
    
    func test_loadImageDataURLTask_doesNotDeliverResultOnCanceledTask() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        var capturedResults = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: url) { capturedResults.append($0) }
        task.cancel()
        
        client.complete(withStatusCode: 200, data: anyData)
        client.complete(withStatusCode: 400, data: Data())
        client.complete(withError: anyNSError())
        
        XCTAssertTrue(capturedResults.isEmpty, "Expected no result after task cancel")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        
        trackMemoryLeaks(instance: client, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private var anyData: Data {
        Data("any data".utf8)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toReceive expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let url = anyURL()
        let exp = expectation(description: "Wait for completion")
        
        sut.loadImageData(from: url) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (let .success(expectedData), let .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
                
            case (let .failure(expectedError as NSError), let .failure(receivedError as NSError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
                
            case (let .failure(expectedError as RemoteFeedImageDataLoader.Error), let .failure(receivedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) match \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
