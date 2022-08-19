//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Andrey on 8/19/22.
//

import Foundation

public class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map(\.local)
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ localFeedImage: LocalFeedImage) {
            self.id = localFeedImage.id
            self.description = localFeedImage.description
            self.location = localFeedImage.location
            self.url = localFeedImage.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let cacheStoreURL: URL
    
    public init(cacheStoreURL: URL) {
        self.cacheStoreURL = cacheStoreURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data(contentsOf: cacheStoreURL) else {
            completion(.empty)
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch(let error) {
            completion(.failure(error))
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let codableFeed = feed.map(CodableFeedImage.init)
            let cache = Cache(feed: codableFeed, timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: cacheStoreURL)
            
            completion(nil)
        } catch(let error) {
            completion(error)
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: cacheStoreURL.path) else {
            completion(nil)
            return
        }
        
        do {
            try FileManager.default.removeItem(at: cacheStoreURL)
            completion(nil)
        } catch(let error) {
            completion(error)
        }
    }
}
