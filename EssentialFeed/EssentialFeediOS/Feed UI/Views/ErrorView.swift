//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Andrey on 9/5/22.
//

import UIKit

public class ErrorView: UIView {
    @IBOutlet private var label: UILabel!
    
    public var message: String? {
        get { isVisible ? label.text : nil }
        set { setMessageAnimated(message: newValue) }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = nil
        alpha = 0
    }
    
    private var isVisible: Bool {
        alpha == 1
    }
    
    private func setMessageAnimated(message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        label.text = message
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.alpha = 1.0
        }
    }
    
    @IBAction private func hideMessageAnimated() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.alpha = 0
        } completion: { [weak self] completed in
            if completed {
                self?.label.text = nil
            }
        }
    }
}
