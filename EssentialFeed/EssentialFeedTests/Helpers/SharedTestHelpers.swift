//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/17/22.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any domain", code: 100)
}

func anyData() -> Data {
    Data("any data".utf8)
}
