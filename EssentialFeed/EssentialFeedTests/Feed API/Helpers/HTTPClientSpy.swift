//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Andrey on 9/10/22.
//

import Foundation
import EssentialFeed

public class HTTPClientSpy: HTTPClient {
    
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        
        func cancel() { callback() }
    }
    
    var messages = [(url: URL, completion: (HTTPClient.Result) -> ())]()
    
    var requestedURLs: [URL] {
        messages.map(\.0)
    }
    
    var canceledURLs = [URL]()
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> ()) -> HTTPClientTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.canceledURLs.append(url)
        }
    }
    
    func complete(withError error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode statusCode: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!
        
        messages[index].completion(.success((response, data)))
    }
}
