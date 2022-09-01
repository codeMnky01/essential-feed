//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 8/27/22.
//

import Foundation
import EssentialFeediOS
import UIKit

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullTuRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewIsVisible(at index: Int = 0) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewIsNotVisible(at index: Int = 0) -> FeedImageCell? {
        let view = simulateFeedImageViewIsVisible(at: index)
        let delegate = tableView.delegate
        let indexPath = IndexPath(item: index, section: sectionForFeedImageViews)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
        return view
    }
    
    func simulateFeedImageViewNearVisible(at index: Int = 0) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(item: index, section: sectionForFeedImageViews)
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedImageViewNotNearVisibleAnymore(at index: Int = 0) {
        simulateFeedImageViewNearVisible(at: index)
        
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(item: index, section: sectionForFeedImageViews)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    private var sectionForFeedImageViews: Int { 0 }
    
    var numberOfRenderedFeedImageViews: Int {
        tableView.numberOfRows(inSection: sectionForFeedImageViews)
    }
    
    func feedImageView(at index: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(item: index, section: sectionForFeedImageViews)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
}
