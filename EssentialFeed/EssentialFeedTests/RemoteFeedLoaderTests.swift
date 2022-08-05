//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/4/22.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs.count, 0)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-other-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-other-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Domain", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        for (index, sample) in samples.enumerated() {
            expect(sut: sut, toCompleteWith: .failure(.invalidData), when: {
                let emptyJSON = makeItemsJSON(items: [])
                client.complete(withStatusCode: sample, data: emptyJSON, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .success([]), when: {
            let emptyJSONList = makeItemsJSON(items: [])
            client.complete(withStatusCode: 200, data: emptyJSONList)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResposneJSONItemList() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://a-url.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https://a-another-url.com")!
        )
        
        let items = [item1.model, item2.model]
        expect(sut: sut, toCompleteWith: .success(items), when: {
            let data = makeItemsJSON(items: [item1.json, item2.json])
            client.complete(withStatusCode: 200, data: data)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any]()) { acc, e in
            if let value = e.value {
                acc[e.key] = value
            }
        }
        
        return (item, json)
    }
    
    private func makeItemsJSON(items: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": items])
    }
    
    private func expect(sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        
        sut.load() { capturedResults.append($0) }
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> ())]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> ()) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(response, data))
        }
    }
}
