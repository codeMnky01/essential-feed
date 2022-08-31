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
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: presenter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        presenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
        presenter.feedLoadingView = refreshController
        
        return feedController
    }
}

private class FeedViewAdapter: FeedView {
    private weak var feedViewController: FeedViewController?
    private var imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.feedViewController = controller
        self.imageLoader = loader
    }
    
    func displayFeed(_ feed: [FeedImage]) {
        feedViewController?.tableModel = feed.map { model in
            let model = FeedImageViewModel<UIImage>(model: model, imageLoader: self.imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: model)
        }
    }
}
