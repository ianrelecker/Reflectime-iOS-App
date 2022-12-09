//
//  Note.swift
//  ReflectimeV9
//
//  Adapted by Ian Relecker from https://github.com/twostraws/hackingwithswift
//  Specifically from Video https://youtu.be/zrJG7EyMPLI
//

import Foundation
import CoreData


class Notes: NSManagedObject {
    
    var reflections: [NoteItem]
    
    init(reflections: [NoteItem]) {
        self.reflections = reflections
    }
    
}
