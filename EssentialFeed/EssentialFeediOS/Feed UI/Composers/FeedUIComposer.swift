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
        let presenter = FeedPresenter()
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader, presenter: presenter)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        presenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
        presenter.feedLoadingView = WeakRefVirtualProxy(refreshController)
        
        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T:FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var feedViewController: FeedViewController?
    private var imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.feedViewController = controller
        self.imageLoader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        feedViewController?.tableModel = viewModel.feed.map { model in
            let model = FeedImageViewModel<UIImage>(model: model, imageLoader: self.imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: model)
        }
    }
}

private class FeedPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    private let feedPresenter: FeedPresenter
    
    init(loader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = loader
        self.feedPresenter = presenter
    }
    
    func didRequestFeedRefresh() {
        feedPresenter.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(feed):
                self.feedPresenter.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self.feedPresenter.didFinishLoadingFeed(with: error)
            }
        }
    }
}
