//
//  LoaderStub.swift
//  EssentialAppTests
//
//  Created by Ljubisa Katana on 17.1.24..
//

import EssentialFeed

class LoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
