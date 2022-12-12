//
//  dataController.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 12/3/22.
//  Adapted from https://www.youtube.com/watch?v=bvm3ZLmwOdU
//  Adapted from https://youtu.be/TsfOYHbf4Ew "B"
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentCloudKitContainer(name: "Reflectime")
    
    
    init(){
        container.loadPersistentStores{ description, error in
            if let error = error {
                print("data error: \(error.localizedDescription)")
            }
        }
        //"B"
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        
        
    }
}
