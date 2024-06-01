//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Adam Bauer on 5/29/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeDelegate = self
        
        loadCategories()

    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        addTodoCategory()
        
    }
    
    //MARK: - Swipekit methods
    
    override func deleteCell(at indexPath: IndexPath) {
        guard let categoryToDelete = categoryArray?[indexPath.row] else {
            return
        }

            do {
                try realm.write {
                    // Delete all items associated with the category
                    realm.delete(categoryToDelete.items)
                    // Delete the category
                    realm.delete(categoryToDelete)
                }
                categoryArray = realm.objects(Category.self)
                
                // Reload the table view data
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        
    }
    
    override func editCell(at indexPath: IndexPath) {
        editCategory(category: categoryArray?[indexPath.row])
    }

}

//MARK: - UITavleViewDataSource Methods

extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // Ensure the data source is updated
            categoryArray = realm.objects(Category.self)
            
            return categoryArray?.count ?? 0
        }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categorys Created yet"
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.randomFlat()
        
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
                    self.tableView.reloadData()
                } catch {
                    self.showErrorAlert(message: "Error updating category name: \(error.localizedDescription)")
                }
            } else {
                self.showErrorAlert(message: "Category name cannot be empty.")
            }
        }
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
        
        self.tableView.reloadData()
    }
}

//MARK: - SwipeTableViewControllerDelegate
extension CategoryViewController: SwipeTableViewControllerDelegate {
    func hasItems(at indexPath: IndexPath) -> Bool {
        if let category = categoryArray?[indexPath.row] {
            return !category.items.isEmpty
        } else {
            return false
        }
    }
}
