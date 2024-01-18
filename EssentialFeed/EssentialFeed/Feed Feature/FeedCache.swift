//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 18.1.24..
//

import Foundation

public protocol FeedCache {
     typealias Result = Swift.Result<Void, Error>

     func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
 }
