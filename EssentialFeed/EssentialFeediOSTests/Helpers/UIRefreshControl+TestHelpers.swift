//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 8/27/22.
//

import UIKit

extension UIRefreshControl {
    func simulatePullTuRefresh() {
        simulate(event: .valueChanged)
    }
}
