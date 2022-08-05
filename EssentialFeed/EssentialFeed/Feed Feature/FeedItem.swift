//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Andrey on 8/3/22.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
