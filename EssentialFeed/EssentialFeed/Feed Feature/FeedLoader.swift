//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Andrey on 8/3/22.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
