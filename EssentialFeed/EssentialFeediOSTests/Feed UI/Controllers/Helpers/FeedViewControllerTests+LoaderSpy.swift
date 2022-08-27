//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 8/27/22.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

extension FeedViewControllerTests {
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - FeedLoader
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        var loadFeedCallCount: Int { feedRequests.count }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "domain", code: 1)
            feedRequests[index](.failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        var loadedImageURLs: [URL] {
            imageRequests.map(\.url)
        }
        
        private(set) var canceledImageURLs = [URL]()
        private(set) var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.canceledImageURLs.append(url) }
        }
        
        func completeImageDataLoading(with data: Data = Data(), at index: Int) {
            imageRequests[index].completion(.success(data))
        }
        
        func completeImageDataLoadingWithError(at index: Int) {
            let error = NSError(domain: "domain", code: 1)
            imageRequests[index].completion(.failure(error))
        }
    }
}
