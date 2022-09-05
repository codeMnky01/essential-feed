//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Andrey on 9/1/22.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        dequeueReusableCell(withIdentifier: "\(T.self)") as! T
    }
}
