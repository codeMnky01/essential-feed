//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/8/22.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> HTTPSessionDataTask
}

protocol HTTPSessionDataTask {
    func resume()
}

class URLSessionHTTPClient: HTTPClient {
    private var session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ()) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
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
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://a-some-url.com")!
        let givenError = NSError(domain: "any error", code: 1)
        let session = URLSessionSpy()
        session.stub(url: url, error: givenError)
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, givenError)
                
            default:
                XCTFail("Should have failed with: \(givenError), but succeeded with: \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: HTTPSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, with task: HTTPSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> HTTPSessionDataTask {
            
            guard let stub = stubs[url] else {
                fatalError("Not found stub for url: \(url)")
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: HTTPSessionDataTask {
        func resume() { }
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionDataTask {
        var resumeCount = 0
        
        func resume() {
            resumeCount += 1
        }
    }
}
