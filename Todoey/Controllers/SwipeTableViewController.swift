//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Adam Bauer on 6/1/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

//MARK: - SwipeTableViewControllerDelegate

protocol SwipeTableViewControllerDelegate: AnyObject {
    func hasItems(at indexPath: IndexPath) -> Bool
}

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    let realm = try! Realm()
    
    weak var swipeDelegate: SwipeTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60
    }
    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("numberOfRowsInSection() must be implemented by subclass")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - SwipeTableViewCellDelegate Methods
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
            
            guard orientation == .right else { return nil }
            
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                self.deleteCell(at: indexPath)
            }
            deleteAction.image = UIImage(named: "delete-icon")
            
            let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
                self.editCell(at: indexPath)
            }
            editAction.image = UIImage(named: "more-icon")
            
            if swipeDelegate?.hasItems(at: indexPath) == true {
                return [editAction]
            } else {
                return [deleteAction, editAction]
            }
        }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        if swipeDelegate?.hasItems(at: indexPath) == true {
            options.expansionStyle = .selection
        } else {
            options.expansionStyle = .destructive
        }
        return options
    }
    
    // MARK: - Alert Methods
    
    func openWindow(title: String, placeholder: String, action: String, initialValue: String? = nil, completion: @escaping (String?) -> Void) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = placeholder
            if let initialValue = initialValue {
                alertTextField.text = initialValue
            }
            textField = alertTextField
        }
        
        let addAction = UIAlertAction(title: action, style: .default) { (action) in
            completion(textField.text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(message: String, title: String = "Error") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
 //MARK: - swipe acctions
    
    func deleteCell(at indexPath: IndexPath) {
        // Delete current cell
    }
    
    func editCell(at indexPath: IndexPath) {
        // Edit current cell
    }
    
}
