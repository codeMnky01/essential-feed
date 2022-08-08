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
        session.dataTask(with: url).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://a-some-url.com")!
        let task = URLSessionDataTaskSpy()
        let session = URLSessionSpy()
        session.stub(url: url, with: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) {_ in }
        
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        private var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, with task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() { }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCount = 0
        
        override func resume() {
            resumeCount += 1
        }
    }
}
