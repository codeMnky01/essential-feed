//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/27/22.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: NSObject {
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
        resetCellForReuse()
    }
    
    private func resetCellForReuse() {
        cell = nil
    }
}

extension FeedImageCellController: FeedImageView {
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.locationLabel.text = viewModel.location
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.setImageAnimated(viewModel.image)
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.feedImageViewContainer.isShimmering = viewModel.isLoading
        
        cell?.onRetry = delegate.didRequestImage
    }
}
