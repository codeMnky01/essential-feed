//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/29/22.
//

import Foundation
import UIKit
import EssentialFeed

final class FeedImageViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    public init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
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
    
    var onImageLoad: Observer<UIImage>?
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
        let image = data.map(UIImage.init) ?? nil
        if let image = image {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        
        onImageLoadingStateChange?(false)
    }
}
