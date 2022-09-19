//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/15/22.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoaderTests {
    
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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedImageDataLoader, FeedImageDataLoaderSpy, FeedImageDataLoaderSpy) {
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primary: primaryLoader,
            fallback: fallbackLoader)
        
        trackMemoryLeaks(instance: primaryLoader, file: file, line: line)
        trackMemoryLeaks(instance: fallbackLoader, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, primaryLoader, fallbackLoader)
    }
}
