//
//  FeedViewController.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 8/25/22.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expect does not load feed after init")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expect load feed on viewDidLoad")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expect load feed on user request")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expect load feed on user request")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect show loading indicator on viewDidLoad")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect hide indicator when complete loading")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect show loading indicator on user load request")
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect hide indicator when user initiated load request complete")
    }
    
    func test_loadCompletion_rendersSuccessfullyLoadedFeed() {
        let (sut, loader) = makeSUT()
        
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: "a description", location: nil)
        let image2 = makeImage(description: nil, location: "a location")
        let image3 = makeImage(description: nil, location: nil)
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
    
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackMemoryLeaks(instance: loader, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "any-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering images: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews == images.count else {
            XCTFail("Expected to render same amount views as loaded", file: file, line: line)
            return
        }
        
        images.enumerated().forEach { (index, image) in
            assertThat(sut, hasViewConfiguredAt: index, with: image)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredAt index: Int, with image: FeedImage, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        guard let cell = view as? FeedImageCell else {
            XCTFail("Expected to get a FeedImageCell, got \(String(describing: view.self)) instead")
            return
        }
        
        XCTAssertEqual(cell.isShowingLocation, image.location != nil, file: file, line: line)
        XCTAssertEqual(cell.locationText, image.location, file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description, file: file, line: line)
    }
    
    class LoaderSpy: FeedLoader {
        private var loadingCompletions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int { loadingCompletions.count }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadingCompletions.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            loadingCompletions[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "domain", code: 1)
            loadingCompletions[index](.failure(error))
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullTuRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    private var sectionForFeedImageViews: Int { 0 }
    
    var numberOfRenderedFeedImageViews: Int {
        tableView.numberOfRows(inSection: sectionForFeedImageViews)
    }
    
    func feedImageView(at index: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(item: index, section: sectionForFeedImageViews)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
}

private extension UIRefreshControl {
    func simulatePullTuRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
