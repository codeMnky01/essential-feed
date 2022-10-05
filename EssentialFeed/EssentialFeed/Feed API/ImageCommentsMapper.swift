//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Andrey on 10/5/22.
//

import Foundation

final class ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(response: HTTPURLResponse, data: Data) throws -> [RemoteFeedItem] {
        guard
            response.isOK,
            let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
}
