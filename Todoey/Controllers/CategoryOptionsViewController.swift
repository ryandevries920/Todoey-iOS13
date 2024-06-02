//
//  CategoryOptionsViewController.swift
//  Todoey
//
//  Created by Adam Bauer on 6/2/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryOptionsViewController: UIViewController {
    
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        do {
            try self.realm.write {
                selectedCategory?.colorRandom()
            }
            updateUI()
        } catch {
            print("error, \(error)")
        }
    }
    
    func updateUI() {
            labelText.text = selectedCategory?.name
            if let bgColorHex = selectedCategory?.bgColor {
                let color = UIColor(hexString: bgColorHex)
                view.backgroundColor = color
                labelText.textColor = UIColor(contrastingBlackOrWhiteColorOn: color!, isFlat: true)
                button.tintColor = UIColor(contrastingBlackOrWhiteColorOn: color!, isFlat: true)
            }
        }
}
