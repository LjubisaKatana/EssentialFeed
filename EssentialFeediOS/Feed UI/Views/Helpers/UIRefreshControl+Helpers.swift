//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Ljubisa Katana on 8.11.23..
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
