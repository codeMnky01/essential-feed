//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Andrey on 8/4/22.
//

import Foundation

final public class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(_ completion: @escaping (Result) -> ()) {
        client.get(from: url) { result in
            switch result {
            case let .success(response, data):
                let mappedResult = FeedItemsMapper.map(response: response, data: data)
                completion(mappedResult)
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
}
