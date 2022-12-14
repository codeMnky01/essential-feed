//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 9/8/22.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesAfterInitialization() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartImageDataLoading_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let feedImage = uniqueImage()
        
        sut.didStartImageDataLoading(for: feedImage)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishImageDataLoading_displayRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT()
        let feedImage = uniqueImage()
        
        sut.didFinishImageDataLoadingWith(data: Data(), for: feedImage)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishImageDataLoading_displayImage() {
        let (sut, view) = makeSUT { _ in AnyImage() }
        let feedImage = uniqueImage()
        
        sut.didFinishImageDataLoadingWith(data: Data(), for: feedImage)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNotNil(message?.image)
    }
    
    func test_didFinishImageDataLoading_displayRetryOnLoadError() {
        let (sut, view) = makeSUT()
        let feedImage = uniqueImage()
        
        sut.didFinishImageDataLoadingWith(error: anyNSError(), for: feedImage)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil }, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(
            view: view,
            imageTransformer: imageTransformer)
        
        trackMemoryLeaks(instance: view, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private struct AnyImage: Equatable {}
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ viewModel: FeedImageViewModel<AnyImage>) {
            messages.append(viewModel)
        }
    }
    
    private var alwaysFailingImageTransformer: (Data) -> AnyImage? {
        { _ in nil }
    }
}
