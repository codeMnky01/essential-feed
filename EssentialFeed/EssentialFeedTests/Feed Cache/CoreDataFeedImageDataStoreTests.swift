//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 9/12/22.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(data: Data, forURL url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}

class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenURLNotMatch() {
        let sut = makeSUT()
        let url = anyURL()
        let otherURL = URL(string: "https://other-url.com")!
        
        sut.insert(data: anyData(), forURL: url) { _ in }
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: otherURL)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeaks(instance: sut)
        return sut
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        .success(.none)
    }
    
    private func localImage(for url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (expectedResult, receivedResult) {
                
            case (let .success(expectedData), let .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func insert(_ data: Data, forURL url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        let image = localImage(for: url)
        sut.insert([image], timestamp: Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                
            case .success:
                sut.insert(data: data, forURL: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                    }
                }
            }
             
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
