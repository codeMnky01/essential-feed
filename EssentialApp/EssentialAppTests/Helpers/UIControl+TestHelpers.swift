//
//  UIControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 8/27/22.
//

import UIKit

extension UIControl {
    func simulate(event: Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
