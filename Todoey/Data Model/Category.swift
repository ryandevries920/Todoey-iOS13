//
//  Category.swift
//  Todoey
//
//  Created by Adam Bauer on 5/30/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    
    // To-many relationship with item
    var items = List<Item>()
    
    convenience init?(as name: String) {
        self.init()
        guard !name.isEmpty else { return nil }
        self.name = name
    }
}
