//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 21.3.23..
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping(Result) -> Void)
}
