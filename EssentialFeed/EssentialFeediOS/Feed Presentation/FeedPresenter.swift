//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/31/22.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final public class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    func didStartLoadingFeed() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView?.display(FeedViewModel(feed: feed))
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    
    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
}
