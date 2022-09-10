//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Andrey on 8/6/22.
//

import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(response: HTTPURLResponse, data: Data) throws -> [RemoteFeedItem] {
        guard
            response.isOK,
            let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
