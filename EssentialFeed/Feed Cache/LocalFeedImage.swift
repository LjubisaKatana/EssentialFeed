//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 22.6.23..
//

import Foundation

/// Mirror the FeedItem model and this is the starting point for module decentralisation.
/// This technique is called DTO (data transfer object) it's just a data transfer representation of the real model
public struct LocalFeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
