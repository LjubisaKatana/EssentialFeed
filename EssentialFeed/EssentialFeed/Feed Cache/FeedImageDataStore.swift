//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 11.1.24..
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
