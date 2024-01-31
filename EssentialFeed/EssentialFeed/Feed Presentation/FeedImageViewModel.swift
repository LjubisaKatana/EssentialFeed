//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 8.1.24..
//

import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        return location != nil
    }
}
