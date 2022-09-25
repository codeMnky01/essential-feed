//
//  XCTestCase+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Andrey on 9/25/22.
//

import XCTest

extension XCTest {
    func assert(_ snapshot: UIImage, name: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let snapshotData = makeSnapshotData(snapshot, file: file, line: line) else {
            return
        }
        
        let snapshotURL = makeSnapshotURL(name, file: file, line: line)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Record snapshot before running tests", file: file, line: line)
            return
        }
        
        if !match(snapshotData, storedSnapshotData, tolerance: 0.00001) {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData.write(to: temporarySnapshotURL)
            
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
    
    private func match(_ oldData: Data, _ newData: Data, tolerance: Float = 0) -> Bool {
        if oldData == newData { return true }
        
        guard let oldImage = UIImage(data: oldData)?.cgImage, let newImage = UIImage(data: newData)?.cgImage else {
            return false
        }
        
        guard oldImage.width == newImage.width, oldImage.height == newImage.height else {
            return false
        }
        
        let minBytesPerRow = min(oldImage.bytesPerRow, newImage.bytesPerRow)
        let bytesCount = minBytesPerRow * oldImage.height
        
        var oldImageByteBuffer = [UInt8](repeating: 0, count: bytesCount)
        guard let oldImageData = data(for: oldImage, bytesPerRow: minBytesPerRow, buffer: &oldImageByteBuffer) else {
            return false
        }
        
        var newImageByteBuffer = [UInt8](repeating: 0, count: bytesCount)
        guard let newImageData = data(for: newImage, bytesPerRow: minBytesPerRow, buffer: &newImageByteBuffer) else {
            return false
        }
        
        if memcmp(oldImageData, newImageData, bytesCount) == 0 { return true }
        
        return match(oldImageByteBuffer, newImageByteBuffer, tolerance: tolerance, bytesCount: bytesCount)
    }
    
    private func data(for image: CGImage, bytesPerRow: Int, buffer: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
        guard
            let space = image.colorSpace,
            let context = CGContext(
                data: buffer,
                width: image.width,
                height: image.height,
                bitsPerComponent: image.bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else { return nil }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        
        return context.data
    }
    
    private func match(_ bytes1: [UInt8], _ bytes2: [UInt8], tolerance: Float, bytesCount: Int) -> Bool {
        var differentBytesCount = 0
        for i in 0 ..< bytesCount where bytes1[i] != bytes2[i] {
            differentBytesCount += 1
            
            let percentage = Float(differentBytesCount) / Float(bytesCount)
            if percentage > tolerance {
                return false
            }
        }
        return true
    }
}
