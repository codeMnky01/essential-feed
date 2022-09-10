//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Andrey on 9/10/22.
//

import Foundation

public final class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((response, data)):
                guard response.statusCode == 200, !data.isEmpty else {
                    task.complete(with: .failure(Error.invalidData))
                    break
                }
                task.complete(with: .success(data))
                
            case let .failure(error):
                task.complete(with: .failure(error))
            }
        }
        
        return task
    }
}
