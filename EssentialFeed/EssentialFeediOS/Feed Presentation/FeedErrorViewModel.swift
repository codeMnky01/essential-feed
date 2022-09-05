//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Andrey on 9/5/22.
//

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: .none)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
