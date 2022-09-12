//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Andrey on 9/12/22.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    public typealias SaveResult = Result<Void, SaveError>
    public enum SaveError: Error {
        case failed
    }
    
    public func save(image data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data: data, forURL: url) { result in
            completion(.failure(SaveError.failed))
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public typealias LoadResult = FeedImageDataLoader.Result
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
        
        let task = LoadImageDataTask(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                })
        }
        return task
    }
}
