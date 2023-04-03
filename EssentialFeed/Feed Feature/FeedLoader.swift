//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 21.3.23..
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader { 
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
