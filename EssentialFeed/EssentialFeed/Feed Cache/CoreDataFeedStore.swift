//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Andrey on 8/20/22.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
    public init() {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}
