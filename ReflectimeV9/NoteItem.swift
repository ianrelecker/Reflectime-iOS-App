//
//  NoteItem.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 10/29/22.
//

import Foundation
import CoreLocation
import CoreData


class NoteItem: NSManagedObject {
    var id = UUID()
    let name: String = ""
    let data: String = ""
    let date = Date()
    let lat: Double = 0.0
    let lon: Double = 0.0
    let cata: String = ""
}

