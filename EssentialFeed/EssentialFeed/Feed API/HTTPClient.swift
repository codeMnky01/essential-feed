//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Andrey on 8/6/22.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ())
}
    