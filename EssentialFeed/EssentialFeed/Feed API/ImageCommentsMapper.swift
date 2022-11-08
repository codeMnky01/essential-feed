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
            isOK(response: response),
            let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
    
    static func isOK(response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
