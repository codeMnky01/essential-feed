//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/20/22.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(feed: feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(feed: feed, timestamp: timestamp, to: sut)
        
        expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let error = insert(feed: uniqueImageFeed().local, timestamp: Date(), to: sut)
        
        XCTAssertNil(error, "Expected to insert cache successfully", file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(feed: uniqueImageFeed().local, timestamp: Date(), to: sut)
        
        let error = insert(feed: uniqueImageFeed().local, timestamp: Date(), to: sut)
        
        XCTAssertNil(error, "Expected to insert cache successfully", file: file, line: line)
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(feed: uniqueImageFeed().local, timestamp: Date(), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        insert(feed: latestFeed, timestamp: latestTimestamp, to: sut)
        
        expect(sut, toRetrieve: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let error = deleteCache(sut)
        
        XCTAssertNil(error, "Expected to complete deletion without an error", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(feed: uniqueImageFeed().local, timestamp: Date(), to: sut)
        
        let error = deleteCache(sut)
        
        XCTAssertNil(error, "Expected to complete deletion without an error", file: file, line: line)
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(feed: uniqueImageFeed().local, timestamp: Date(), to: sut)
        
        deleteCache(sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatStoreSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        var expectationsOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { error in
            expectationsOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { error in
            expectationsOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { error in
            expectationsOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(expectationsOrder, [op1, op2, op3], file: file, line: line)
    }
}

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(feed: [LocalFeedImage], timestamp: Date, to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var error: Error?
        sut.insert(feed, timestamp: timestamp) { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return error
    }
    
    @discardableResult
    func deleteCache(_ sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var error: Error?
        sut.deleteCachedFeed { deletionError in
            error = deletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return error
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for completion")
        sut.retrieve { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success(.none), .success(.none)), (.failure, .failure):
                break
                
            case let (.success(.some(expectedCache)), .success(.some(receivedCache))):
                XCTAssertEqual(expectedCache.feed, receivedCache.feed, file: file, line: line)
                XCTAssertEqual(expectedCache.timestamp, receivedCache.timestamp, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) results, got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
