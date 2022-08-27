//
//  FeedViewControllerTests+Assertions.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 8/27/22.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedViewControllerTests {
    func assertThat(_ sut: FeedViewController, isRendering images: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews == images.count else {
            XCTFail("Expected to render same amount views as loaded", file: file, line: line)
            return
        }
        
        images.enumerated().forEach { (index, image) in
            assertThat(sut, hasViewConfiguredAt: index, with: image)
        }
    }

    func assertThat(_ sut: FeedViewController, hasViewConfiguredAt index: Int, with image: FeedImage, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        guard let cell = view as? FeedImageCell else {
            XCTFail("Expected to get a FeedImageCell, got \(String(describing: view.self)) instead")
            return
        }
        
        XCTAssertEqual(cell.isShowingLocation, image.location != nil, file: file, line: line)
        XCTAssertEqual(cell.locationText, image.location, file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description, file: file, line: line)
    }
}
