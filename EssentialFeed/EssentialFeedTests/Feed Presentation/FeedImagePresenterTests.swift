//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 9/8/22.
//

import XCTest
import EssentialFeed

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}

protocol FeedImageView {
    func display(_ viewModel: FeedImageViewModel)
}

final class FeedImagePresenter {
    private let view: FeedImageView
    
    init(view: FeedImageView) {
        self.view = view
    }
    
    func didStartImageDataLoading(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
}

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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        
        trackMemoryLeaks(instance: view, file: file, line: line)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel]()
        
        func display(_ viewModel: FeedImageViewModel) {
            messages.append(viewModel)
        }
    }
}
