//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 21.3.23..
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completions: @escaping(LoadFeedResult<Error>) -> Void)
}
