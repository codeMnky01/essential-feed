//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/27/22.
//

import Combine
import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {
        
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        
        let feedController = makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title)
        
        presentationAdapter.feedPresenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                loader: imageLoader),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController))
        
        return feedController
    }
    
    private static func makeWith( delegate: FeedLoaderPresentationAdapter, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.title = FeedPresenter.title
        feedController.delegate = delegate
        return feedController
    }
}
