//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/27/22.
//

import UIKit

final class FeedImageCellController: NSObject {
    private var viewModel: FeedImageViewModel<UIImage>
    
    public init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    private(set) lazy var view: FeedImageCell = {
        let view = binded(FeedImageCell())
        viewModel.loadImageDate()
        return view
    }()
    
    func preload() {
        viewModel.preloadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelLoadImageData()
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationLabel.text = viewModel.location
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageDate

        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            if isLoading {
                cell?.feedImageViewContainer.startShimmering()
            } else {
                cell?.feedImageViewContainer.stopShimmering()
            }
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
}
