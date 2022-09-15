//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/15/22.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "domain", code: 100)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}
