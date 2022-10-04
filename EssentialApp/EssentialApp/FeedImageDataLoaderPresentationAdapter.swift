//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Andrey on 9/2/22.
//

import Combine
import UIKit
import EssentialFeed
import EssentialFeediOS

class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private var model: FeedImage
    private var imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: AnyCancellable?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = loader
    }
    
    func didRequestImage() {
        presenter?.didStartImageDataLoading(for: model)
        let model = self.model
        
        cancellable = imageLoader(model.url).sink { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishImageDataLoadingWith(error: error, for: model)
            }
        } receiveValue: { [weak self] data in
            self?.presenter?.didFinishImageDataLoadingWith(data: data, for: model)
        }
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
