//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Andrey on 9/2/22.
//

import UIKit
import EssentialFeed

class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, loader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = loader
    }
    
    func didRequestImage() {
        presenter?.didStartImageDataLoading(for: model)
        let model = self.model
        
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishImageDataLoadingWith(data: data, for: model)
                
            case let .failure(error):
                self?.presenter?.didFinishImageDataLoadingWith(error: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
}
