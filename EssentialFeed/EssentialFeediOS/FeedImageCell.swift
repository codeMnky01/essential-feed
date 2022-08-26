//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/26/22.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageViewContainer = ShimmeringView()
    public let feedImageView = UIImageView()
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(retryCallback), for: .touchUpInside)
        return btn
    }()
    
    var onRetry: (() -> Void)?
    
    @objc func retryCallback() {
        onRetry?()
    }
}
