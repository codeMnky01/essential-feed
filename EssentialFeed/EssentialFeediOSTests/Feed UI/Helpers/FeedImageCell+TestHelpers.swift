//
//  FeedImageCell.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 8/27/22.
//

import Foundation
import EssentialFeediOS

extension FeedImageCell {
    func simulateRetryButtonTap() {
        feedImageRetryButton.simulateTap()
    }
    
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var isShowingLoadingIndicator: Bool {
        feedImageViewContainer.isShimmering
    }
    
    var isShowingRetryButton: Bool {
        !feedImageRetryButton.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
}
