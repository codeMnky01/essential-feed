//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Andrey on 9/8/22.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private var imageTransformer: (Data) -> Image?
    
    public init(view: View, transformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = transformer
    }
    
    public func didStartImageDataLoading(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    private struct InvalidDataImageError: Error {}
    
    public func didFinishImageDataLoadingWith(data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishImageDataLoadingWith(error: InvalidDataImageError(), for: model)
        }
        
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: false))
    }
    
    public func didFinishImageDataLoadingWith(error: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
