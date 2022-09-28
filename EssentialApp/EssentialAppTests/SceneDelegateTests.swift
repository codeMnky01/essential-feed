//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Andrey on 9/23/22.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

class SceneDelegateTests: XCTestCase {
    func test_configureWindow_configuresWindowAsKeyAndMakesItVisible() {
        let sut = SceneDelegate()
        let window = UIWindowSpy()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCount, 1, "Expect to make window key and visible")
    }
    
    func test_sceneWillConnectToSession_configuresRootViewcontroller() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let feed = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation)
        XCTAssertTrue(feed is FeedViewController)
    }
    
    // MARK: - Helpers
    
    private class UIWindowSpy: UIWindow {
        var makeKeyAndVisibleCount = 0
        override func makeKeyAndVisible() {
            makeKeyAndVisibleCount += 1
        }
    }
}
