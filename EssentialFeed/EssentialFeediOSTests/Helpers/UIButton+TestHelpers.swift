//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 8/27/22.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
