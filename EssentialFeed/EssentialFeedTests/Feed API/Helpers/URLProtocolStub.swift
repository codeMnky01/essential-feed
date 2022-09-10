//
//  URLProtocolStub.swift
//  EssentialFeedTests
//
//  Created by Andrey on 9/10/22.
//

import Foundation

class URLProtocolStub: URLProtocol {
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> ())?
    }
    
    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    private static var _stub: Stub?
    private static var stub: Stub? {
        get { queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }
    
    static func stub(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        stub = Stub(data: data, response: response, error: error, requestObserver: nil)
    }
    
    static func observeRequests(with observer: @escaping (URLRequest) -> ()) {
        stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        
        stub.requestObserver?(request)
    }
    
    override func stopLoading() {}
    
    static func removeStub() {
        stub = nil
    }
}
