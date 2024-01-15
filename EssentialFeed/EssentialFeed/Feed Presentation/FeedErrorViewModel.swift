//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 24.11.23..
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
