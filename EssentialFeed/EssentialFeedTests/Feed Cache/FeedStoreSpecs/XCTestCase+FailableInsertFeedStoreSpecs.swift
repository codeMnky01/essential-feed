//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/20/22.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let error = insert(feed: uniqueImageFeed().local, timestamp: Date(), to: sut)
        
        XCTAssertNotNil(error, "Expected cache insertion to fail with an error", file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(feed: uniqueImageFeed().local, timestamp: Date(), to: sut)
        
        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}
