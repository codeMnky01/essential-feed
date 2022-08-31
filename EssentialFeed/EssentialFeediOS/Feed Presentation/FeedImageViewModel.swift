//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Andrey on 8/29/22.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}
