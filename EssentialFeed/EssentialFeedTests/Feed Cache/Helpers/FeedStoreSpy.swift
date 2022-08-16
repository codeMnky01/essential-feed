//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/16/22.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
    enum ReceivedMessage: Equatable {
        case delete
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    private (set) var receivedMessages = [ReceivedMessage]()
    
    // MARK: - Deletion
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.delete)
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    // MARK: - Insertion
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error: NSError, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    // MARK: - Retrieval
    func retrieve() {
        receivedMessages.append(.retrieve)
    }
}
