//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Ljubisa Katana on 4.9.23..
//

import UIKit
import EssentialFeed

final class FeedViewModel {
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    
    private enum State {
        case pending
        case loading
        case loaded([FeedImage])
        case failed
    }
    
    private var state = State.pending {
        didSet { onChange? (self) }
    }
    
    var isLoading: Bool {
        switch state {
        case .loading: return true
        case .pending, .loaded, .failed: return false
        }
    }
    
    var feed: [FeedImage]? {
        switch state {
        case let .loaded(feed): return feed
        case .pending, .loading, .failed: return nil
        }
    }
        
    func loadFeed() {
        state = .loading
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.state = .loaded(feed)
            } else {
                self?.state = .failed
            }
        }
    }
}


final class FeedRefreshViewController: NSObject {
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        bind(view)
        return view
    }()

    private let viewModel: FeedViewModel
    
    init(feedLoader: FeedLoader) {
        self.viewModel = FeedViewModel(feedLoader: feedLoader)
    }

    var onRefresh: (([FeedImage]) -> Void)?

    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func bind(_ view: UIRefreshControl) {
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
            
            if let feed = viewModel.feed {
                self?.onRefresh?(feed)
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
}
