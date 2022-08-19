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
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated)
    private let cacheStoreURL: URL
    
    public init(cacheStoreURL: URL) {
        self.cacheStoreURL = cacheStoreURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = cacheStoreURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
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
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = cacheStoreURL
        queue.async {
            do {
                let encoder = JSONEncoder()
                let codableFeed = feed.map(CodableFeedImage.init)
                let cache = Cache(feed: codableFeed, timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                
                completion(nil)
            } catch(let error) {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = cacheStoreURL
        queue.async {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                completion(nil)
                return
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch(let error) {
                completion(error)
            }
        }
    }
}
