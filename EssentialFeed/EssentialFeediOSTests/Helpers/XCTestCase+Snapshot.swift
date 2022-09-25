//
//  XCTestCase+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 9/25/22.
//

import XCTest

extension XCTest {
    func assert(_ snapshot: UIImage, name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot, file: file, line: line)
        let snapshotURL = makeSnapshotURL(name, file: file, line: line)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Record snapshot before running tests", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("Snapshots does not match. Stored: \(snapshotURL), New: \(temporarySnapshotURL)", file: file, line: line)
        }
    }
    
    func record(_ snapshot: UIImage, name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot, file: file, line: line)
        let snapshotURL = makeSnapshotURL(name, file: file, line: line)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Unable to write file at url: \(snapshotURL) with error: \(error)")
        }
    }
    
    func makeSnapshotData(_ image: UIImage, file: StaticString = #filePath, line: UInt = #line) -> Data? {
        guard let data = image.pngData() else {
            XCTFail("Unable to get Data from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }
    
    func makeSnapshotURL(_ name: String, file: StaticString = #filePath, line: UInt = #line) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
}
