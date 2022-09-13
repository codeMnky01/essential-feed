//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Andrey on 8/21/22.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    // MARK: - LocalFeedLoader Tests
    
    func test_loadFeed_deliversNoItemsOnEmptyCache() {
        let feedLoader = makeFeedLoader()
        
        expect(feedLoader, toLoad: [])
    }
    
    func test_loadFeed_deliversItemsSavedOnASeparateInstance() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let savedItems = uniqueImageFeed().models
        
        save(savedItems, with: feedLoaderToPerformSave)
        
        expect(feedLoaderToPerformLoad, toLoad: savedItems)
    }
    
    func test_saveFeed_overridesItemsSavedOnASeparateInstance() {
        let feedLoaderToPerformFirstSave = makeFeedLoader()
        let feedLoaderToPerformLastSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let firstSavedItems = uniqueImageFeed().models
        let lastSavedItems = uniqueImageFeed().models
        
        save(firstSavedItems, with: feedLoaderToPerformFirstSave)
        save(lastSavedItems, with: feedLoaderToPerformLastSave)
        
        expect(feedLoaderToPerformLoad, toLoad: lastSavedItems)
    }
    
    func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformValidation = makeFeedLoader()
        let feed = uniqueImageFeed().models
        
        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformSave, toLoad: feed)
    }
    
    func test_validateFeedCache_deletesFeedSavedInDistantPast() {
        let feedLoaderToPerformSave = makeFeedLoader(currentDate: .distantPast)
        let feedLoaderToPerformValidation = makeFeedLoader()
        let feed = uniqueImageFeed().models
        
        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformSave, toLoad: [])
    }
    
    // MARK: - LocalFeedImageDataLoader Tests
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let firstImageLoader = makeImageLoader()
        let lastImageLoader = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueImage()
        let dataToSave = anyData()
        
        save([image], with: feedLoader)
        save(dataToSave, for: image.url, with: firstImageLoader)
        
        expect(lastImageLoader, toLoad: dataToSave, for: image.url)
    }
    
    func test_saveImageData_overridesSavedDataOnASeparateInstance() {
        let firstImageLoaderToPerformSave = makeImageLoader()
        let lastImageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueImage()
        let firstImageData = Data("first image data".utf8)
        let lastImageData = Data("first image data".utf8)
        
        save([image], with: feedLoader)
        save(firstImageData, for: image.url, with: firstImageLoaderToPerformSave)
        save(lastImageData, for: image.url, with: lastImageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: lastImageData, for: image.url)
    }
    
    // MARK: - Helpers
    
    private func makeFeedLoader(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
    
        trackMemoryLeaks(instance: store, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func makeImageLoader(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
    
        trackMemoryLeaks(instance: store, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(_ sut: FeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch receivedResult {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save successfully")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func validateCache(with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        loader.validateCache { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected success, got: \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: FeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: url) { receivedResult in
            switch receivedResult {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ data: Data, for url: URL, with sut: LocalFeedImageDataLoader, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.save(image: data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save successfully")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectoryURL().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectoryURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
