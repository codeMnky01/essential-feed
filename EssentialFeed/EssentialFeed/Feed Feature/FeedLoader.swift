//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Andrey on 8/3/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult)->())
}
