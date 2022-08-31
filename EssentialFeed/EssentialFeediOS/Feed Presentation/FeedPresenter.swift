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
    
    func didStartLoadingFeed() {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
