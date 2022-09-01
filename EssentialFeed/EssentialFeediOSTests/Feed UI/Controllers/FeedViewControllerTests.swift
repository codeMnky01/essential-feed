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
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let bundle = Bundle(for: FeedViewController.self)
        let localizedKey = "FEED_VIEW_TITLE"
        let localizedTitle = bundle.localizedString(forKey: localizedKey, value: nil, table: "Feed")
        
        XCTAssertNotEqual(localizedKey, localizedTitle, "Missing localized string for key: \(localizedKey)")
        XCTAssertEqual(sut.title, localizedTitle)
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expect does not load feed after init")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expect load feed on viewDidLoad")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expect load feed on user request")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expect load feed on user request")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect show loading indicator on viewDidLoad")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect hide indicator when complete loading succeeds")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect show loading indicator on user load request")
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect hide indicator when user initiated load request fails with an error")
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
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(url: URL(string: "http://any-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://any-url-1.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewIsVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])
        
        sut.simulateFeedImageViewIsVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageView_cancelsLoadingImageFromURLWhenViewIsNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(url: URL(string: "http://any-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://any-url-1.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [])
        
        sut.simulateFeedImageViewIsNotVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [image0.url])
        
        sut.simulateFeedImageViewIsNotVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(url: URL(string: "http://any-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://any-url-1.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        let view0 = sut.simulateFeedImageViewIsVisible(at: 0)
        let view1 = sut.simulateFeedImageViewIsVisible(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)
        
        loader.completeImageDataLoading(at: 0)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)
        
        loader.completeImageDataLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false)
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage()
        let image1 = makeImage()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewIsVisible(at: 0)
        let view1 = sut.simulateFeedImageViewIsVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let imageData0 = UIImage.make(with: .blue).pngData()!
        loader.completeImageDataLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let imageData1 = UIImage.make(with: .red).pngData()!
        loader.completeImageDataLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0)
        XCTAssertEqual(view1?.renderedImage, imageData1)
    }
    
    func test_feedImageView_showsRetryButtonOnLoadError() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage()
        let image1 = makeImage()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewIsVisible(at: 0)
        let view1 = sut.simulateFeedImageViewIsVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        XCTAssertEqual(view1?.isShowingRetryButton, false)
        
        let imageData0 = UIImage.make(with: .blue).pngData()!
        loader.completeImageDataLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        XCTAssertEqual(view1?.isShowingRetryButton, false)
        
        loader.completeImageDataLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        XCTAssertEqual(view1?.isShowingRetryButton, true)
    }
    
    func test_feedImageView_showsRetryButtonOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        let image = makeImage()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image], at: 0)
        
        let view = sut.simulateFeedImageViewIsVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryButton, false)
        
        let imageData = Data("A invalid image data".utf8)
        loader.completeImageDataLoading(with: imageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryButton, true)
    }
    
    func test_feedImageView_reloadImageOnRetryButtonTap() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(url: URL(string: "http://any-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://any-url-1.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewIsVisible(at: 0)
        let view1 = sut.simulateFeedImageViewIsVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
        
        loader.completeImageDataLoadingWithError(at: 0)
        loader.completeImageDataLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
        
        view0?.simulateRetryButtonTap()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url])
        
        view1?.simulateRetryButtonTap()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url])
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(url: URL(string: "http://any-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://any-url-1.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageView_cancelPreloadingImageURLWhenNotNearVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(url: URL(string: "http://any-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://any-url-1.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [])
        
        sut.simulateFeedImageViewNotNearVisibleAnymore(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [image0.url])
        
        sut.simulateFeedImageViewNotNearVisibleAnymore(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()], at: 0)
        
        let view = sut.simulateFeedImageViewIsNotVisible(at: 0)
        loader.completeImageDataLoading(with: anyImageData(), at: 0)
        
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when cell is not visible and should be reset for reuse preparation")
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        
        trackMemoryLeaks(instance: loader, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "any-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(with: .red).pngData()!
    }
}
