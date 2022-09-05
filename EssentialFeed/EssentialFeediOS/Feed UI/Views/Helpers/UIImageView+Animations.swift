//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by Andrey on 9/1/22.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.3) { [weak self] in
            self?.alpha = 1
        }
    }
}
