//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/15/22.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryResultOnPrimarySuccess() {
        let primaryFeed = uniqueImageFeed()
        let fallbackFeed = uniqueImageFeed()
        
        let sut = makeSUT(with: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch receivedResult {
            case let .success(receivedFeed):
                XCTAssertEqual(primaryFeed, receivedFeed)
                
            default:
                XCTFail("Expected successful feed load, got: \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversFallbackResultOnPrimaryFailure() {
        let fallbackFeed = uniqueImageFeed()
        
        let sut = makeSUT(with: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch receivedResult {
            case let .success(receivedFeed):
                XCTAssertEqual(fallbackFeed, receivedFeed)
                
            default:
                XCTFail("Expected successful feed load, got: \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
    
    func trackMemoryLeaks(instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated, otherwise it is potential memory leak", file: file, line: line)
        }
    }
    
    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: "description", location: "location", url: URL(string: "https://url.com")!)
    }
    
    private func uniqueImageFeed() -> [FeedImage] {
        [uniqueImage(), uniqueImage(), uniqueImage(), uniqueImage()]
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "domain", code: 100)
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
}
