//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/8/22.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient: HTTPClient {
    private var session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ()) {
        session.dataTask(with: url)
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_createdDataTaskWithGivenURL() {
        let url = URL(string: "https://a-some-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) {_ in }
        
        XCTAssertEqual(session.requestedURLs,[url])
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var requestedURLs = [URL]()
        
        override func dataTask(with url: URL) -> URLSessionDataTask {
            requestedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask { }
}
