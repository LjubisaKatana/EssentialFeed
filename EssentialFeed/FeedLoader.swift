//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 21.3.23..
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    
    // I can start with Error type but it can bear risk.
    // Can unnecessary damage/complicate the current design.
    // On the other hand error case we don't know and don't need to know yet
    // all errors this feature will have to handle.
    case error(Error)
}

protocol FeedLoader {
    func load(completions: @escaping(LoadFeedResult) -> Void)
}
