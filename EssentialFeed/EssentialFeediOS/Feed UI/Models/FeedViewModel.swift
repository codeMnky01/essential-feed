//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/29/22.
//

import Foundation
import EssentialFeed

final public class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var feedLoader: FeedLoader
    
    var onLoadingStateChange: Observer<Bool>?
    var onLoadFeed: Observer<[FeedImage]>?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            
            if let feed = try? result.get() {
                self.onLoadFeed?(feed)
            }
            
            self.onLoadingStateChange?(false)
        }
    }
}
