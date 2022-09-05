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

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    private let feedErrorView: FeedErrorView
    
    init(loadingView: FeedLoadingView, feedView: FeedView, feedErrorView: FeedErrorView) {
        self.feedLoadingView = loadingView
        self.feedView = feedView
        self.feedErrorView = feedErrorView
    }
    
    static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "")
    }
    
    static var errorMessage: String {
        NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "")
    }
    
    func didStartLoadingFeed() {
        feedErrorView.display(FeedErrorViewModel(message: .none))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        feedErrorView.display(FeedErrorViewModel(message: FeedPresenter.errorMessage))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
