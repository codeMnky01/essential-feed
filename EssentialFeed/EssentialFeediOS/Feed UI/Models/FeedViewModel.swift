//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/29/22.
//

import Foundation
import EssentialFeed

final public class FeedViewModel {
    private var feedLoader: FeedLoader
    
    private(set) var isLoading = false {
        didSet { onStateChange?(self) }
    }
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onStateChange: ((FeedViewModel) -> Void)?
    var onLoadFeed: (([FeedImage]) -> Void)?
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            
            if let feed = try? result.get() {
                self.onLoadFeed?(feed)
            }
            
            self.isLoading = false
        }
    }
}
