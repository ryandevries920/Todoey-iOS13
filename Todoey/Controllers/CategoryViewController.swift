//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Adam Bauer on 5/29/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()

    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        addTodoCategory()
        
    }
}

//MARK: - UITavleViewDataSource Methods

extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categorys Created yet"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate Methods

extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
}

//MARK: - Add new or edit Item

extension CategoryViewController {
    
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
        
        let addAction = UIAlertAction(title: action, style: .default) { [weak self] (action) in
            guard let self = self else { return }
            
            completion(textField.text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        // Assuming self is a UIViewController
        self.present(alert, animated: true, completion: nil)
    }

    func addTodoCategory() {
        openWindow(title: "Add new category", placeholder: "Name to add", action: "Add") { newName in
            if let name = newName, !name.isEmpty {
                if let newCategory = Category(as: name) {
                    do {
                        try self.realm.write {
                            self.realm.add(newCategory)
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } catch {
                        self.showErrorAlert(message: "Error saving new category: \(error.localizedDescription)")
                    }
                } else {
                    self.showErrorAlert(message: "Invalid category name.")
                }
            } else {
                self.showErrorAlert(message: "Category name cannot be empty.")
            }
        }
    }
    
    func editCategory(category: Category?) {
        openWindow(title: "Edit category name", placeholder: "New name", action: "Save", initialValue: category?.name) { newName in
            if let name = newName, !name.isEmpty {
                do {
                    try self.realm.write {
                        category!.name = name
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    self.showErrorAlert(message: "Error updating category name: \(error.localizedDescription)")
                }
            } else {
                self.showErrorAlert(message: "Category name cannot be empty.")
            }
        }
    }
    
    func showErrorAlert(message: String, title: String = "Error") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
//MARK: - File Managment

extension CategoryViewController {
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}

//MARK: - Swipekit methods

extension CategoryViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in

            if let category = self.categoryArray?[indexPath.row] {
                if category.items.count == 0 {
                    do {
                        try self.realm.write {
                            self.realm.delete(category)
                        }
                    } catch {
                        print("Error \(error)")
                    }
                } else {
                    self.showErrorAlert(message: "Delete Items in Category first", title: "Warning")
                }
            }
            self.tableView.reloadData()
        }

        deleteAction.image = UIImage(named: "delete")
        
        let editAction = SwipeAction(style: .default, title: "Edit") { [self] action, indexPath in
            self.editCategory(category: categoryArray?[indexPath.row])
        }

        return self.categoryArray?[indexPath.row].items.count == 0 ? [deleteAction, editAction] : [editAction]
    }
    
}
