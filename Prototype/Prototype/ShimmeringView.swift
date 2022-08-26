//
//  ShimmeringView.swift
//  Prototype
//
//  Created by Andrey on 8/25/22.
//

import UIKit

public class ShimmeringView: UIView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if isShimmering {
            stopShimmering()
            startShimmering()
        }
    }
    
    public var isShimmering: Bool {
        layer.mask?.animation(forKey: shimmeringAnimationKey) != nil
    }
    
    public func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = bounds.width
        let height = bounds.height
        
        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width * 3, height: height)
        layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.1, 0.2, 0.3]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmeringAnimationKey)
    }
    
    public func stopShimmering() {
        layer.mask = nil
    }
    
    private var shimmeringAnimationKey: String {
        "shimmer"
    }
}
