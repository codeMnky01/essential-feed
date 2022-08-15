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
    
    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> ()) {
        store.deleteCachedFeed { [weak self] delitionError in
            guard let self = self else { return }
            
            if let delitionError = delitionError {
                completion(delitionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(items, timestamp: self.currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }
}
