//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 9/1/22.
//

import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let localizedValue = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if localizedValue == key {
            XCTFail("Missing localization for key: \(key) in table: \(table)")
        }
        
        return localizedValue
    }
}
