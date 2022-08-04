//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Andrey on 8/4/22.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?) -> ())
}

final public class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(_ completion: @escaping (Error?) -> ()) {
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}
