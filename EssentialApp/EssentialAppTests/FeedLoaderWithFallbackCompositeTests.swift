//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/15/22.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
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
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        
        let sut = FeedLoaderWithFallbackComposite(
            primary: primaryLoader,
            fallback: fallbackLoader)
        
        trackMemoryLeaks(instance: primaryLoader, file: file, line: line)
        trackMemoryLeaks(instance: fallbackLoader, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(_ sut: FeedLoaderWithFallbackComposite, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (let .success(receivedFeed), let .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed)
                
            case (let .failure(receivedError as NSError), let .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError)
                
            default:
                XCTFail("Expected successful feed load, got: \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
    
    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: "description", location: "location", url: URL(string: "https://url.com")!)
    }

    private func uniqueImageFeed() -> [FeedImage] {
        [uniqueImage(), uniqueImage(), uniqueImage(), uniqueImage()]
    }
}
