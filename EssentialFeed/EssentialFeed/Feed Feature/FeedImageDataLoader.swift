//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Ljubisa Katana on 31.8.23..
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
