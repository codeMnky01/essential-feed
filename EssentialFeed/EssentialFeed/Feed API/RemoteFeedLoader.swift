//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Andrey on 8/4/22.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> ()) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(response, data):
                let mappedResult = FeedItemsMapper.map(response: response, data: data)
                completion(mappedResult)
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
}
