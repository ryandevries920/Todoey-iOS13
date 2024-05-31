//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Adam Bauer on 5/29/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
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

//MARK: - Add new Item

extension CategoryViewController {
    
    func addTodoCategory() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "New Category", message: nil, preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new category, Leave empty to cancel"
            textField = alertTextField
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            
            if let name = textField.text, !name.isEmpty {
                if let newCategory = Category(as: name) {
                    do {
                        try realm.write {
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
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
