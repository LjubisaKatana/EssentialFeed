//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 8.1.24..
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool

    public var hasLocation: Bool {
        return location != nil
    }
}
