//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 31.1.24..
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?

    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }

    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
