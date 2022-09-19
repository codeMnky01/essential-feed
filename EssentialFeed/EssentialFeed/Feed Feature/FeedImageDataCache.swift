//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Andrey on 9/19/22.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(image data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
