//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/26/22.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
