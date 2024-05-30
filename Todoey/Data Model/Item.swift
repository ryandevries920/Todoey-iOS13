//
//  Item.swift
//  Todoey
//
//  Created by Adam Bauer on 5/30/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    
    var perentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
