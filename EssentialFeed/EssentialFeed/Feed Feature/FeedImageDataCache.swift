//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 19.1.24..
//

import Foundation


public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ data: Data, for url: URL) throws
}
