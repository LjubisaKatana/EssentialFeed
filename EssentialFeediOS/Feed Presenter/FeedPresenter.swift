//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Ljubisa Katana on 12.9.23..
//

import EssentialFeed
 
protocol FeedLoadingView: AnyObject { // only class can be weakly referenced
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}
    
final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    weak var loadingView: FeedLoadingView?
        
    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            
            self?.loadingView?.display(isLoading: false)
        }
    } 
}
