//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 9/25/22.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class FeedSnapshotTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
    
        record(sut.snapshot(), name: "EMPTY_FEED")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
    
        record(sut.snapshot(), name: "FEED_WITH_CONTENT")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
         
        sut.display(.error(message: "This is a \nmulti-line\n error message"))
        
        record(sut.snapshot(), name: "FEED_WITH_ERROR_MESSAGE")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
         
        sut.display(feedWithFailedImageLoading())
        
        record(sut.snapshot(), name: "FEED_WITH_FAILED_IMAGE_LOADING")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let vc = storyboard.instantiateInitialViewController() as! FeedViewController
        vc.loadViewIfNeeded()
        return vc
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        []
    }
    
    private func feedWithContent() -> [ImageStub] {
        [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(with: .blue)),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(with: .red))
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        [
            ImageStub(
                description: .none,
                location: "Cannon Street, London",
                image: .none),
            ImageStub(
                description: .none,
                location: "Brighton Seafront",
                image: .none)
        ]
    }
    
    private func record(_ snapshot: UIImage, name: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let data = snapshot.pngData() else {
            XCTFail("Unable to get Data from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            try data.write(to: snapshotURL)
        } catch {
            XCTFail("Unable to write file at url: \(snapshotURL) with error: \(error)")
        }
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    weak var controller: FeedImageCellController?
    private let viewModel: FeedImageViewModel<UIImage>
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil)
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {}
}

extension FeedViewController {
    fileprivate func display(_ stubs: [ImageStub]) {
        let cellControllers = stubs.map { stub in
            let controller = FeedImageCellController(delegate: stub)
            stub.controller = controller
            return controller
        }
        
        display(cellControllers)
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}
