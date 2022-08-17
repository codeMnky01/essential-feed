//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/17/22.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any desc", location: "any loc", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (models, local)
}

extension Date {
    func minusMaxCacheAge() -> Date {
        adding(days: -maxCacheAgeInDays)
    }
    
    var maxCacheAgeInDays: Int { 7 }
    
    private func adding(days: Int) -> Date {
        Calendar.init(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        addingTimeInterval(seconds)
    }
}
