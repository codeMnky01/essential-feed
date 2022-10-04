//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Andrey on 9/13/22.
//

import Combine
import CoreData
import UIKit
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
    }()
    
    private lazy var remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
    private lazy var localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    convenience init(store: FeedStore & FeedImageDataStore, httpClient: HTTPClient) {
        self.init()
        self.store = store
        self.httpClient = httpClient
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    // MARK: - Helpers
    
    func configureWindow() {
        window?.rootViewController = UINavigationController(rootViewController:  FeedUIComposer.feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithFallbackToLocalFeedLoader,
                imageLoader: makeLocalImageDataLoaderWithFallbackToRemoteImageDataLoader))
        
        window?.makeKeyAndVisible()
    }
    
    private func makeRemoteFeedLoaderWithFallbackToLocalFeedLoader() -> FeedLoader.Publisher {
        remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeLocalImageDataLoaderWithFallbackToRemoteImageDataLoader(for url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        
        return localImageLoader
            .loadImageDataPublisher(for: url)
            .fallback(to: {
                remoteImageLoader
                    .loadImageDataPublisher(for: url)
                    .caching(to: localImageLoader, for: url)
            })
    }
}
