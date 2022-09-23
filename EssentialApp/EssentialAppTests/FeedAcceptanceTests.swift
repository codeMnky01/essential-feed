//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/23/22.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let store = InMemoryFeedStore.empty
        let client = HTTPClientStub.online(response)
        let feed = launch(with: store, client: client)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews, 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineClient = HTTPClientStub.online(response)
        let onlineFeed = launch(with: sharedStore, client: onlineClient)
        
        XCTAssertEqual(onlineFeed.numberOfRenderedFeedImageViews, 2)
        XCTAssertEqual(onlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(onlineFeed.renderedFeedImageData(at: 1), makeImageData())
        
        let offlineClient = HTTPClientStub.offline
        let offlineFeed = launch(with: sharedStore, client: offlineClient)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews, 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(with: .empty, client: .offline)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews, 0)
    }
    
    func test_onEnteringBackground_deletesExpiredCache() {
        let store = InMemoryFeedStore.withExpiredCache
        
        enterBackground(with: store)
        
        XCTAssertNil(store.feedCache)
    }
    
    func test_onEnteringBackground_keepsNonExpiredCache() {
        let store = InMemoryFeedStore.withNonExpiredCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.feedCache)
    }
    
    // MARK: - Helpers
    
    private func launch(with store: InMemoryFeedStore, client: HTTPClientStub = .offline) -> FeedViewController {
        let sut = SceneDelegate(store: store, httpClient: client)
        
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    
    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(store: store, httpClient: HTTPClientStub.offline)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private func response(for url: URL) -> (HTTPURLResponse, Data) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: [:])!
        return (response, makeData(for: url))
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        UIImage.make(with: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
}
