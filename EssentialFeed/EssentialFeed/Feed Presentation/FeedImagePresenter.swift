//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 8.1.24..
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location)
    }
}
