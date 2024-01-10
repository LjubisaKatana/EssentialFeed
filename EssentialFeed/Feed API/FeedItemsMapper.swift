//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 31.3.23..
//

import Foundation

 final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private init() {}
    
    // Explanation: "Since we're representing a value type (Int), a class constant and a computed var are equivalent in this context. It's a matter of personal preference."
    private static var OK_200: Int { return 200 } // Why we use this one instead of static let OK_200: Int = 200

     static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
         guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
             throw RemoteFeedLoader.Error.invalidData
         }

         return root.items
     }
}
// Since we have this mapper in own module and we don't want to have it accessible to other modules, we can mark it as `internal` It's by default but it's nice to have it visually
//
// Also we don't want this to be subclassed so we should mark it as `final`
