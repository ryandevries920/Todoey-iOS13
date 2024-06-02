//
//  CategoryViewCell.swift
//  Todoey
//
//  Created by Adam Bauer on 6/2/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

class CategoryViewCell: SwipeTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var itemCount: UILabel!
    
    
}
