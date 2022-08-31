//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/31/22.
//

import Foundation
import EssentialFeed

public protocol FeedLoadingView: AnyObject {
    func displayLoadingState(_ isLoading: Bool)
}

public protocol FeedView {
    func displayFeed(_ feed: [FeedImage])
}

final public class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    weak var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    func loadFeed() {
        feedLoadingView?.displayLoadingState(true)
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            
            if let feed = try? result.get() {
                self.feedView?.displayFeed(feed)
            }
            
            self.feedLoadingView?.displayLoadingState(false)
        }
    }
}
