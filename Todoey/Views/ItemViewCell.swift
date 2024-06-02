//
//  ItemViewCell.swift
//  Todoey
//
//  Created by Adam Bauer on 6/2/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol ItemViewCellDelegate: AnyObject {
    func didTapCheckButton(in cell: ItemViewCell)
    func didTapCell(in cell: ItemViewCell)
}

class ItemViewCell: SwipeTableViewCell {

    weak var customDelegate: ItemViewCellDelegate?
    
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGesture()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupGesture() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
            contentView.addGestureRecognizer(tapGesture)
        }

    @IBAction func checkButtonPressed(_ sender: UIButton) {
        customDelegate?.didTapCheckButton(in: self)
    }

    @objc private func cellTapped() {
        customDelegate?.didTapCell(in: self)
    }
}
