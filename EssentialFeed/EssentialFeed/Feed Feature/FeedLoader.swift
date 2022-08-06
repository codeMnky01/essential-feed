//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Andrey on 8/3/22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
