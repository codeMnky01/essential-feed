//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Andrey on 9/19/22.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> ())
}
