//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Andrey on 8/4/22.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ())
}

final public class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(_ completion: @escaping (Error) -> ()) {
        client.get(from: url) { result in
            switch result {
            case .success(_, _):
                completion(.invalidData)
            case .failure(_):
                completion(.connectivity)
            }
        }
    }
}
