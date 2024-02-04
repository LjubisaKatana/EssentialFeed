//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 18.1.24..
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
