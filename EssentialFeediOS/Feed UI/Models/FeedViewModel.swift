//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Ljubisa Katana on 7.9.23..
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: ((Bool) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
        
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            
            self?.onLoadingStateChange?(false)
        }
    }
}
