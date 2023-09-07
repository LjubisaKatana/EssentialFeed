//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Ljubisa Katana on 4.9.23..
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
     
    private(set) lazy var view = binded(UIRefreshControl())

    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    var onRefresh: (([FeedImage]) -> Void)?

    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
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
        return view
    }
}
