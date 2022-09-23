//
//  HTTPClientStub.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/23/22.
//

import Foundation
import EssentialFeed

class HTTPClientStub: HTTPClient {
    private let stub: (URL) -> HTTPClient.Result
    
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    init(stub: @escaping (URL) -> HTTPClient.Result) {
        self.stub = stub
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> ()) -> EssentialFeed.HTTPClientTask {
        completion(stub(url))
        return Task()
    }
    
    static func online(_ stub: @escaping (URL) -> (HTTPURLResponse, Data)) -> HTTPClientStub {
        HTTPClientStub { url in .success(stub(url)) }
    }
    
    static var offline: HTTPClientStub {
        HTTPClientStub { _ in .failure(NSError(domain: "offline", code: 0)) }
    }
}
