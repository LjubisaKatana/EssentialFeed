//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 11.1.24..
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
