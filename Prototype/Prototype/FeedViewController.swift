//
//  FeedViewController.swift
//  Prototype
//
//  Created by Andrey on 8/24/22.
//

import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

final class FeedViewController: UITableViewController {
    private let feed = FeedImageViewModel.prototypeFeed
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

extension FeedImageCell {
    func configure(with model: FeedImageViewModel) {
        locationContainer.isHidden = model.location == nil
        locationLabel.text = model.location
        
        descriptionLabel.isHidden = model.description == nil
        descriptionLabel.text = model.description
        
        feedImageView.image = UIImage(named: model.imageName)
    }
}
