//
//  UITableView+HeaderSizing.swift
//  EssentialFeediOS
//
//  Created by Andrey on 9/25/22.
//

import UIKit

extension UITableView {
    func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else {
            return
        }
        
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        guard header.frame.height != size.height else {
            return
        }
        
        header.frame.size.height = size.height
        tableHeaderView = header
    }
}
