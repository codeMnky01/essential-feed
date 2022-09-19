//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/19/22.
//

import XCTest
import EssentialFeed

protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(image data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache

    init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.cache.save(image: data, for: url) { _ in }
            }
            
            completion(result)
        }
    }
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTests {
    func test_load_doesNotLoadDataOnInit() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty)
    }
    
    func test_load_loadsFromLoader() {
        let (sut, loader) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [anyURL()])
    }
    
    func test_load_cancelsLoaderTaskOnCancel() {
        let (sut, loader) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url])
    }
    
    func test_load_deliversDataOnLoaderSuccess() {
        let (sut, loader) = makeSUT()
        let data = Data("any data".utf8)
        
        expect(sut, toCompleteWith: .success(data)) {
            loader.completeWith(data)
        }
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            loader.completeWithError(anyNSError())
        }
    }
    
    func test_load_cachesLoadedDataOnLoaderSuccess() {
        let data = Data("any data".utf8)
        let url = anyURL()
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: url) { _ in }
        loader.completeWith(data)
        
        XCTAssertEqual(cache.messages, [.save(data: data, url: url)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(cache: CacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> (FeedImageDataLoader, FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        
        trackMemoryLeaks(instance: loader, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private class CacheSpy: FeedImageDataCache {
        private(set) var messages = [Message]()
        enum Message: Equatable {
            case save(data: Data, url: URL)
        }
        
        func save(image data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            messages.append(.save(data: data, url: url))
            completion(.success(()))
        }
    }
}
