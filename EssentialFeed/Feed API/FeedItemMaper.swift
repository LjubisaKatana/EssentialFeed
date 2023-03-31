//
//  FeedItemMaper.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 31.3.23..
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            return items.map { $0.item }
        }
    }

    private struct Item: Decodable  {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    // Explanation: "Since we're representing a value type (Int), a class constant and a computed var are equivalent in this context. It's a matter of personal preference."
    private static var OK_200: Int { return 200 } // Why we use this one instead of static let OK_200: Int = 200
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        
        return .success(root.feed)
    }
}

// Since we have this mapper in own module and we don't want to have it accessible to other modules, we can mark it as `internal` It's by default but it's nice to have it visually
//
// Also we don't want this to be subclassed so we should mark it as `final`
