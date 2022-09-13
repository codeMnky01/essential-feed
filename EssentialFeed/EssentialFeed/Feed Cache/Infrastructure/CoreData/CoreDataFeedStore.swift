//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Andrey on 8/20/22.
//

import CoreData

public class CoreDataFeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer
            .load(modelName: "FeedStore", storeURL: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
}
