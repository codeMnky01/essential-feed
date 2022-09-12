//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Andrey on 9/12/22.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
