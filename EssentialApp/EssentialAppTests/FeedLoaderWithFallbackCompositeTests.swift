//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/15/22.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTests {
    func test_load_deliversPrimaryResultOnPrimarySuccess() {
        let primaryFeed = uniqueImageFeed()
        let fallbackFeed = uniqueImageFeed()
        
        let sut = makeSUT(with: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_load_deliversFallbackResultOnPrimaryFailure() {
        let fallbackFeed = uniqueImageFeed()
        
        let sut = makeSUT(with: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_load_deliversFailedResultOnBothFailure() {
        let sut = makeSUT(with: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(with primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        let primaryLoader = FeedLoaderStub(result: primaryResult)
        let fallbackLoader = FeedLoaderStub(result: fallbackResult)
        
        let sut = FeedLoaderWithFallbackComposite(
            primary: primaryLoader,
            fallback: fallbackLoader)
        
        trackMemoryLeaks(instance: primaryLoader, file: file, line: line)
        trackMemoryLeaks(instance: fallbackLoader, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return sut
    }
}
