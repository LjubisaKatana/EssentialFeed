//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 21.3.23..
//

import Foundation

public struct FeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(url: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = url
        self.description = description
        self.location = location
        self.url = imageURL
    }
}
