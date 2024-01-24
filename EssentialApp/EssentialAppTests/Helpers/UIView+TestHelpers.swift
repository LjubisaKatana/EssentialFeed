//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Ljubisa Katana on 24.1.24..
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
