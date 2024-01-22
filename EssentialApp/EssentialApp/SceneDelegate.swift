//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Ljubisa Katana on 15.1.24..
//

import UIKit
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

                 let remoteClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
                 let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
                 let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)

                 window?.rootViewController = FeedUIComposer.feedComposedWith(
                     feedLoader: remoteFeedLoader,
                     imageLoader: remoteImageLoader)
    }

}
