//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 9/1/22.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let presentationBundle = Bundle(for: FeedPresenter.self)
        let localizationBundles = allLocalizationBundles(in: presentationBundle)
        let localizationStringKeys = allLocalizationStringKeys(in: localizationBundles, table: table)
        
        localizationBundles.forEach { (bundle, localization) in
            localizationStringKeys.forEach { key in
                let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
                
                if localizedString == key {
                    let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
                    XCTFail("Missing language: \(language) (\(localization)) in table: \(table)")
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private typealias LocalizedBundle = (bundle: Bundle, localization: String)
    
    private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #filePath, line: UInt = #line) -> [LocalizedBundle] {
        bundle.localizations.compactMap { localization in
            guard
                let path = bundle.path(forResource: localization, ofType: "lproj"),
                let localizedBundle = Bundle(path: path)
            else {
                XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line:  line)
                return nil
            }
            
            return (localizedBundle, localization)
        }
    }
    
    private func allLocalizationStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #filePath, line: UInt = #line) -> Set<String> {
        bundles.reduce([]) { acc, current in
            guard
                let path = current.bundle.path(forResource: table, ofType: "strings"),
                let strings = NSDictionary(contentsOfFile: path),
                let keys = strings.allKeys as? [String]
            else {
                XCTFail("Couldn't load localized strings for localization: \(current.localization)", file: file, line:  line)
                return []
            }
            
            return acc.union(Set(keys))
        }
    }
}
