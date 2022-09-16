//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/15/22.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    NSError(domain: "domain", code: 100)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "description", location: "location", url: URL(string: "https://url.com")!)
}

func uniqueImageFeed() -> [FeedImage] {
    [uniqueImage(), uniqueImage(), uniqueImage(), uniqueImage()]
}
