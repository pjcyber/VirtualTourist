//
//  DataController.swift
//  VirtualTourist
//
//  Created by Pjcyber on 5/7/20.
//  Copyright © 2020 Pjcyber. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    private init() {}
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "VirtualTourist")
        container.loadPersistentStores(completionHandler: { _, error in
          
            if let error = error as NSError? {
                fatalError("DataController error \(error.localizedDescription)")
            }
            
        })
        return container
    }()
    
    static func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nerror = error as NSError
                fatalError("DataController error \(nerror.localizedDescription)")
            }
        }
    }
}
