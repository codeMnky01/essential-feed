//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/4/22.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesntHaveRequestURL() {
        let client = HTTPClient()
        let _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestURL)
    }
}
