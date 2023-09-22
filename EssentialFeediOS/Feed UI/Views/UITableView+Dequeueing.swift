//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Ljubisa Katana on 22.9.23..
//

import Foundation

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
