//
//  DebuggingSceneDelegate.swift
//  EssentialApp
//
//  Created by Andrey on 9/22/22.
//

#if DEBUG

import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS

class DebuggingSceneDelegate: SceneDelegate {
    override func makeRootViewController() -> UIViewController {
        let storeURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite")

        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: storeURL)
        }
        
        return super.makeRootViewController()
    }
    
    override func makeRemoteClient() -> HTTPClient {
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
        
        return super.makeRemoteClient()
    }
}

private class AlwaysFailingHTTPClient: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> ()) -> EssentialFeed.HTTPClientTask {
        completion(.failure(NSError(domain: "offline", code: 0)))
        return Task()
    }
}
#endif
