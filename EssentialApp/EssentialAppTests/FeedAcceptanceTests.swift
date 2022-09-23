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
        let store = InMemoryStore.empty
        let client = HTTPClientStub.online(response)
        let feed = launch(with: store, client: client)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews, 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryStore.empty
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
    
    // MARK: - Helpers
    
    private func launch(with store: InMemoryStore, client: HTTPClientStub) -> FeedViewController {
        let sut = SceneDelegate(store: store, httpClient: client)
        
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    
    private class InMemoryStore: FeedStore, FeedImageDataStore {
        private var feedCache: CachedFeed?
        private var feedImageDataCache = [URL: Data]()
        
        static var empty: InMemoryStore {
            InMemoryStore()
        }
        
        func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
            completion(.success(feedCache))
        }
        
        func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
            feedCache = (feed, timestamp)
        }
        
        func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
            feedCache = nil
            completion(.success(()))
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            completion(.success(feedImageDataCache[url]))
        }
        
        func insert(data: Data, forURL url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            feedImageDataCache[url] = data
            completion(.success(()))
        }
    }
    
    private class HTTPClientStub: HTTPClient {
        private let stub: (URL) -> HTTPClient.Result
        
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> ()) -> EssentialFeed.HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static func online(_ stub: @escaping (URL) -> (HTTPURLResponse, Data)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url)) }
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub { _ in .failure(NSError(domain: "offline", code: 0)) }
        }
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
