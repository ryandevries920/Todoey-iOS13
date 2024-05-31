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
    @objc dynamic var dateCreated: Date?
    
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
    var formattedDate: String? {
        guard let date = dateCreated else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    convenience init?(as name: String) {
        self.init()
        guard !name.isEmpty else { return nil }
        self.title = name
        self.dateCreated = Date()
    }
    
    
}

