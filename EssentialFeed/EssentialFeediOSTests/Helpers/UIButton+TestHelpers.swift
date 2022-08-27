//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 8/27/22.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
