//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Andrey on 8/15/22.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping (() -> Date)) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> ()) {
        store.deleteCachedFeed { [weak self] delitionError in
            guard let self = self else { return }
            
            if let delitionError = delitionError {
                completion(delitionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            
            completion(insertionError)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
