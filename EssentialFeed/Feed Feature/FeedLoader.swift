//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 21.3.23..
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader { 
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
