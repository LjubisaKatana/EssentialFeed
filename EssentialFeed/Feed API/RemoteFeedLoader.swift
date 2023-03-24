//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 22.3.23..
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping(Error) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error { // domain error
        case connectivity
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping(Error) -> Void) {
        client.get(from: url) { error in
            completion(.connectivity) //
        }
//        client.get(from: url) // this is the unexpected behaviour for example
        // we have to guarantee to have last passed value
    }
}
