//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Andrey on 8/15/22.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
