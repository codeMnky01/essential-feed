//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Andrey on 8/15/22.
//

import Foundation

public enum CacheRetrievalResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp:   Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (CacheRetrievalResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
