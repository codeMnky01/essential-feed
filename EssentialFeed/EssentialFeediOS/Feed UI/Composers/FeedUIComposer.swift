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
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = adaptFeedImagesToCellControllers(forwardingTo: feedViewController, using: imageLoader)
        
        return feedViewController
    }
    
    private static func adaptFeedImagesToCellControllers(forwardingTo feedViewController: FeedViewController, using imageLoader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
    }
}
