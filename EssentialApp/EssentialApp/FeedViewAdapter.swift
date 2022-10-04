//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Andrey on 9/2/22.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
    private weak var feedViewController: FeedViewController?
    private var imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.feedViewController = controller
        self.imageLoader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        feedViewController?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, loader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        })
    }
}
