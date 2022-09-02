//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/31/22.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    
    init(loadingView: FeedLoadingView, feedView: FeedView) {
        self.feedLoadingView = loadingView
        self.feedView = feedView
    }
    
    static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "")
    }
    
    func didStartLoadingFeed() {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in
                self?.didStartLoadingFeed()
            }
        }
        
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in
                self?.didFinishLoadingFeed(with: feed)
            }
        }
        
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in
                self?.didFinishLoadingFeed(with: error)
            }
        }
        
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
