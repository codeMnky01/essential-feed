//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/19/22.
//

import Foundation
import EssentialFeed

public class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private(set) var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()
    
    var loadedURLs: [URL] {
        messages.map(\.url)
    }
    
    private struct Task: FeedImageDataLoaderTask {
        let callback: () -> Void
        
        func cancel() {
            callback()
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task { [weak self] in self?.cancelledURLs.append(url) }
    }
    
    func completeWith(_ data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
    
    func completeWithError(_ error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
}
