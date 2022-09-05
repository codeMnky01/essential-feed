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
        get { label.text }
        set { label.text = newValue }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = nil
    }
}
