//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/9/22.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackMemoryLeaks(instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated, otherwise it is potential memory leak", file: file, line: line)
        }
    }
}
