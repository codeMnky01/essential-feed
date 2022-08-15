//
//  EssentialFeedEndToEndAPITests.swift
//  EssentialFeedEndToEndAPITests
//
//  Created by Andrey on 8/10/22.
//

import XCTest
import EssentialFeed

class EssentialFeedEndToEndAPITests: XCTestCase {
    
    func test_endToEndServerGETFeedResult_matchesFixedTestData() {
        switch getFeedResult() {
        case let .success(feed):
            XCTAssertEqual(feed[0], image(for: 0))
            XCTAssertEqual(feed[1], image(for: 1))
            XCTAssertEqual(feed[2], image(for: 2))
            XCTAssertEqual(feed[3], image(for: 3))
            XCTAssertEqual(feed[4], image(for: 4))
            XCTAssertEqual(feed[5], image(for: 5))
            XCTAssertEqual(feed[6], image(for: 6))
            XCTAssertEqual(feed[7], image(for: 7))
            
        case let .failure(error):
            XCTFail("Failed with \(error), expected success instead")
            
        default:
            XCTFail("Failed with no result, expected success instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> LoadFeedResult? {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5c52cdd0b8a045df091d2fff/1548930512083/feed-case-study-test-api-feed.json")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: url, client: client)
        
        trackMemoryLeaks(instance: client, file: file, line: line)
        trackMemoryLeaks(instance: loader, file: file, line: line)
        
        let exp = expectation(description: "wait for request completion")
        var capturedResult: LoadFeedResult?
        loader.load { result in
            capturedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3)
        
        return capturedResult
    }
    
    private func image(for index: Int) -> FeedImage {
        return FeedImage(
            id: idForImage(at: index),
            description: descriptionForImage(at: index),
            location: locationForImage(at: index),
            url: imageURLForImage(at: index)
        )
    }
    
    private func idForImage(at index: Int) -> UUID {
        [
            UUID(uuidString: "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6")!,
            UUID(uuidString: "BA298A85-6275-48D3-8315-9C8F7C1CD109")!,
            UUID(uuidString: "5A0D45B3-8E26-4385-8C5D-213E160A5E3C")!,
            UUID(uuidString: "FF0ECFE2-2879-403F-8DBE-A83B4010B340")!,
            UUID(uuidString: "DC97EF5E-2CC9-4905-A8AD-3C351C311001")!,
            UUID(uuidString: "557D87F1-25D3-4D77-82E9-364B2ED9CB30")!,
            UUID(uuidString: "A83284EF-C2DF-415D-AB73-2A9B8B04950B")!,
            UUID(uuidString: "F79BD7F8-063F-46E2-8147-A67635C3BB01")!,
        ][index]
    }
    
    private func descriptionForImage(at index: Int) -> String? {
        [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8",
        ][index]
    }
    
    private func locationForImage(at index: Int) -> String? {
        [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8",
        ][index]
    }
    
    private func imageURLForImage(at index: Int) -> URL {
        URL(string: "https://url-\(index + 1).com")!
    }
}
