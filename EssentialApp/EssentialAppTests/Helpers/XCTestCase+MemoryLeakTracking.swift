//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/15/22.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeaks(instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated, otherwise it is potential memory leak", file: file, line: line)
        }
    }
}
