//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 22.6.23..
//

import Foundation

internal struct RemoteFeedItem: Decodable  {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
