//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/27/22.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        feedViewModel.onLoadFeed = adaptFeedImagesToCellControllers(forwardingTo: feedViewController, using: imageLoader)
        
        return feedViewController
    }
    
    private static func adaptFeedImagesToCellControllers(forwardingTo feedViewController: FeedViewController, using imageLoader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map { model in
                let feedImageViewModel = FeedImageViewModel(model: model, imageLoader: imageLoader)
                return FeedImageCellController(viewModel: feedImageViewModel)
            }
        }
    }
}
