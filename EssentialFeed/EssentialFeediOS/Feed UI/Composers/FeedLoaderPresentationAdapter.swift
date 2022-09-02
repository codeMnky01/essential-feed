//
//  FeedPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Andrey on 9/2/22.
//

import Foundation
import EssentialFeed

class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: FeedLoader
    var feedPresenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.feedLoader = loader
    }
    
    func didRequestFeedRefresh() {
        feedPresenter?.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(feed):
                self.feedPresenter?.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self.feedPresenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
