//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 22.6.23..
//

import Foundation

 struct RemoteFeedItem: Decodable  {
     let id: UUID
     let description: String?
     let location: String?
     let image: URL
}
