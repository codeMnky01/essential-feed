//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/18/22.
//

import XCTest
import EssentialFeed

private struct Cache: Codable {
    let feed: [LocalFeedImage]
    let timestamp: Date
}

class CodableFeedStore {
    private let cacheStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("imagefeed.store")
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        let decoder = JSONDecoder()
        
        guard
            let data = try? Data(contentsOf: cacheStoreURL),
            let cache = try? decoder.decode(Cache.self, from: data)
        else {
            completion(.empty)
            return
        }
        
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed, timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: cacheStoreURL)
        
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    private let cacheStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("imagefeed.store")
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: cacheStoreURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? FileManager.default.removeItem(at: cacheStoreURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for completion")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for completion")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected same results, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertionToEmptyCache_deliversInsertedValues() {
        let sut = CodableFeedStore()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for completion")
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected nil, got \(insertionError!)")
            
            sut.retrieve { retrievingResult in
                switch retrievingResult {
                case let .found(feed: foundFeed, timestamp: foundTimestamp):
                    XCTAssertEqual(feed, foundFeed)
                    XCTAssertEqual(timestamp, foundTimestamp)
                    
                default:
                    XCTFail("Expected \(feed) and \(timestamp), got \(retrievingResult)")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
