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
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeDelegate = self
        
        loadCategories()
        
        registerTableViewCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setupNavBar()
        tableView.reloadData()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        addTodoCategory()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "gotoCategoryOptions" {
            prepareForFirstSegue(segue, sender: sender)
        } else if segue.identifier == "goToItems" {
            prepareForSecondSegue(segue, sender: sender)
        }
    }
    
    
    //MARK: - navBar setup
    
    func setupNavBar () {
        let color = UIColor.flatBlue()
        guard let navBar = navigationController?.navigationBar else {fatalError("NavBar not found.")}
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: color, isFlat:true)]
        navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: color, isFlat:true)]
        navBarAppearance.backgroundColor = color
        navBar.prefersLargeTitles = true
        navBar.isTranslucent = false
        navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat:true)
        navBar.standardAppearance = navBarAppearance
        navBar.scrollEdgeAppearance = navBarAppearance
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
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "gotoCategoryOptions", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    private func prepareForFirstSegue(_ segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CategoryOptionsViewController {
            if let indexPath = selectedIndexPath {
                destinationVC.selectedCategory = categoryArray?[indexPath.row]
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryViewCell", for: indexPath) as! CategoryViewCell
        
        cell.delegate = self

        if let category = categoryArray?[indexPath.row] {
            let color = UIColor(hexString: category.bgColor)
            cell.labelText?.text = category.name
            cell.itemCount?.text = "\(String(itemsLeft(indexPath: indexPath))) of \(String(category.items.count))"
            cell.backgroundColor = color
            cell.labelText?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color!, isFlat: true)
            cell.itemCount?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color!, isFlat: true)
        }

        return cell
    }
    
}

//MARK: - UITableViewDelegate Methods

extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    private func prepareForSecondSegue(_ segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TodoListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoryArray?[indexPath.row]
            }
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

//MARK: - Custom ViewCell

extension CategoryViewController {
    
    private func registerTableViewCells() {
        let labelFieldCell = UINib(nibName: "CategoryViewCell", bundle: nil)
        self.tableView.register(labelFieldCell, forCellReuseIdentifier: "CategoryViewCell")
    }
    
    func itemsLeft (indexPath: IndexPath) -> Int {
        
        if let category = categoryArray?[indexPath.row] {
            var count: Int = 0
            for item in category.items {
                if !item.done {
                    count += 1
                }
            }
            return count
        } else {
            return 0
        }
        
    }
}
