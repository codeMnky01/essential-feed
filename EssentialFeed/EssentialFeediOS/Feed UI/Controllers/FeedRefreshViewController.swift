//
//  FeedRefreshingViewController.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/27/22.
//

import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject {
    private var feedLoader: FeedLoader
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            
            if let feed = try? result.get() {
                self.onRefresh?(feed)
            }
            
            self.view.endRefreshing()
        }
    }
}
