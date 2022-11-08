//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 10/5/22.
//

import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs.count, 0)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-other-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-other-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Domain", code: 0)
            client.complete(withError: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 150, 300, 400, 500]
        
        for (index, code) in samples.enumerated() {
            expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
                let emptyJSON = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, data: emptyJSON, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseInvalidJSON() {
        let (sut, client) = makeSUT()
        let samples = [200, 201, 250, 280, 299]
        
        for (index, code) in samples.enumerated() {
            expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
                let invalidJSON = Data("invalid JSON".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            })
        }
    }
    
    func test_load_deliversNoItemsOn2xxHTTPResponseEmptyJSONList() {
        let (sut, client) = makeSUT()
        let samples = [200, 201, 250, 280, 299]
        
        for (index, code) in samples.enumerated() {
            expect(sut: sut, toCompleteWith: .success([]), when: {
                let emptyJSONList = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, data: emptyJSONList, at: index)
            })
        }
    }
    
    func test_load_deliversItemsOn2xxHTTPResponseJSONItemList() {
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
        let samples = [200, 201, 250, 280, 299]
        
        for (index, code) in samples.enumerated() {
            expect(sut: sut, toCompleteWith: .success(items), when: {
                let data = makeItemsJSON(items: [item1.json, item2.json])
                client.complete(withStatusCode: code, data: data, at: index)
            })
        }
    }
    
    func test_load_doestNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://some-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
        
        var capturedResults = [RemoteImageCommentsLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON(items: []))
        
        XCTAssert(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemoteImageCommentsLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        
        trackMemoryLeaks(instance: client, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(items: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": items])
    }
    
    private func expect(sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Waiting for load to complete")
        
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
                
            case let (.success(expectedItems), .success(receivedItems)):
                XCTAssertEqual(expectedItems, receivedItems, file: file, line: line)
                
            case let (.failure(expectedError as RemoteImageCommentsLoader.Error), .failure(receivedError as RemoteImageCommentsLoader.Error)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
                
            default:
                XCTFail("expected: \(expectedResult) but received: \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
