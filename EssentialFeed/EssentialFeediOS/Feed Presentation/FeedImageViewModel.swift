//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/29/22.
//

import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    private var imageTransformer: (Data) -> Image?
    
    public init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var hasLocation: Bool {
        location != nil
    }
    
    var location: String? {
        model.location
    }
    
    var description: String? {
        model.description
    }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageDate() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func preloadImageData() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }
    
    func cancelLoadImageData() {
        task?.cancel()
        task = nil
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        let data = try? result.get()
        let image = data.map(imageTransformer) ?? nil
        if let image = image {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        
        onImageLoadingStateChange?(false)
    }
}
