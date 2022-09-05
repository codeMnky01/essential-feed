//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Andrey on 9/5/22.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
