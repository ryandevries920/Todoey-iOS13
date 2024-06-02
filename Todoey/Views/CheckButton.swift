//
//  CheckButton.swift
//  Todoey
//
//  Created by Adam Bauer on 6/2/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit

class CheckButton: UIButton {
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupButton()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupButton()
        }

        private func setupButton() {
            setImage(UIImage(systemName: "square"), for: .normal)
            setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
            tintColor = .systemBlue
            addTarget(self, action: #selector(toggleSelected), for: .touchUpInside)
            translatesAutoresizingMaskIntoConstraints = false
        }

        @objc private func toggleSelected() {
            isSelected.toggle()
        }
    
}
