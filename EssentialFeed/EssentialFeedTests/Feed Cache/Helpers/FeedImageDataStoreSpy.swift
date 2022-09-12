//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Andrey on 9/12/22.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    private(set) var messages = [Message]()
    private var retrieveCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var saveCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
    
    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }
    
    func insert(data: Data, forURL url: URL, completion: @escaping (InsertionResult) -> Void) {
        messages.append(.insert(data: data, for: url))
        saveCompletions.append(completion)
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        messages.append(.retrieve(dataFor: url))
        retrieveCompletions.append(completion)
    }
    
    func completeRetrievalWithError(_ error: Error, at index: Int = 0) {
        retrieveCompletions[index](.failure(error))
    }
    
    func completeRetrievalWith(_ data: Data?, at index: Int = 0) {
        retrieveCompletions[index](.success(data))
    }
}
