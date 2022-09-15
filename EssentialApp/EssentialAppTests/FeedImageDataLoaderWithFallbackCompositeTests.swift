//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/15/22.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_load_doesNotLoadDataOnInit() {
        let (_, primary, fallback) = makeSUT()
        
        XCTAssertTrue(primary.loadedURLs.isEmpty)
        XCTAssertTrue(fallback.loadedURLs.isEmpty)
    }
    
    func test_load_loadsFromPrimaryLoaderFirst() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primary.loadedURLs, [anyURL()])
        XCTAssertTrue(fallback.loadedURLs.isEmpty)
    }
    
    func test_load_cancelsPrimaryLoaderTaskOnCancel() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(primary.cancelledURLs, [url])
        XCTAssertEqual(fallback.cancelledURLs, [])
    }
    
    func test_load_cancelsFallbackLoaderTaskOnPrimaryFailureAndCancel() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        primary.completeWithError(anyNSError())
        task.cancel()
        
        XCTAssertEqual(primary.cancelledURLs, [])
        XCTAssertEqual(fallback.cancelledURLs, [url])
    }
    
    func test_load_deliversPrimaryDataOnPrimarySuccess() {
        let (sut, primary, _) = makeSUT()
        let primaryData = Data("primary data".utf8)
        
        expect(sut, toCompleteWith: .success(primaryData)) {
            primary.completeWith(primaryData)
        }
    }
    
    func test_load_deliversFallbackDataOnPrimaryFailure() {
        let (sut, primary, fallback) = makeSUT()
        let fallbackData = Data("primary data".utf8)
        
        expect(sut, toCompleteWith: .success(fallbackData)) {
            primary.completeWithError(anyNSError())
            fallback.completeWith(fallbackData)
        }
    }
    
    func test_load_deliversErrorOnBothPrimaryAndFallbackFailure() {
        let (sut, primary, fallback) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            primary.completeWithError(anyNSError())
            fallback.completeWithError(anyNSError())
        }
    }
                           
    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (let .success(expectedData), let .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
                
            case (let .failure(expectedError as NSError), let .failure(receivedError as NSError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedImageDataLoaderWithFallbackComposite, LoaderSpy, LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primary: primaryLoader,
            fallback: fallbackLoader)
        
        trackMemoryLeaks(instance: primaryLoader, file: file, line: line)
        trackMemoryLeaks(instance: fallbackLoader, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "domain", code: 100)
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private(set) var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        private(set) var cancelledURLs = [URL]()
        
        var loadedURLs: [URL] {
            messages.map(\.url)
        }
        
        private struct Task: FeedImageDataLoaderTask {
            let callback: () -> Void
            
            func cancel() {
                callback()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task { [weak self] in self?.cancelledURLs.append(url) }
        }
        
        func completeWith(_ data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
        
        func completeWithError(_ error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
