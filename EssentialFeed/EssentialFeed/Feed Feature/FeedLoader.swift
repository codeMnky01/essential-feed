//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Andrey on 8/3/22.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
