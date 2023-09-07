//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ljubisa Katana on 5.9.23..
//

import EssentialFeed

public final class FeedUIComposer {
     private init() {}

     public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
         let feedViewModel = FeedViewModel(feedLoader: feedLoader)
         let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
         let feedController = FeedViewController(refreshController: refreshController)
         refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
         return feedController
     }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader:
                                                   FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: loader)
            }
        }
    }
}
