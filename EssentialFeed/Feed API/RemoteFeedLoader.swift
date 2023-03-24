//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 22.3.23..
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping(Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error { // domain error
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping(Error) -> Void) {
        client.get(from: url) { error, response in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
        }
    }
}
