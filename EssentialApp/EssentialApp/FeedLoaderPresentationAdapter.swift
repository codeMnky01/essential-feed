//
//  FeedPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Andrey on 9/2/22.
//

import Foundation
import Combine
import EssentialFeed
import EssentialFeediOS

class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> FeedLoader.Publisher
    private var cancellable: AnyCancellable?
    var feedPresenter: FeedPresenter?
    
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        feedPresenter?.didStartLoadingFeed()
        
        cancellable = feedLoader().sink(
            receiveCompletion: { [weak self] completion in
                print("======", completion)
                switch completion {
                case .finished: break
                case let .failure(error):
                    print("=============", error)
                    self?.feedPresenter?.didFinishLoadingFeed(with: error)
                }
            },
            receiveValue: { [weak self] feed in
                self?.feedPresenter?.didFinishLoadingFeed(with: feed)
            }
        )
    }
}
