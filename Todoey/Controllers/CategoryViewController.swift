//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Adam Bauer on 5/29/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        return categoryArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate Methods

extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let category = categoryArray[indexPath.row]
        
//        category.done = !category.done
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        print(category.name!)
        saveCategories()
        
        DispatchQueue.main.async { self.tableView.reloadData() }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Add new Item

extension CategoryViewController {
    
    func addTodoCategory() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "New Category", message: nil, preferredStyle: .alert)
        alert.addTextField { (alertTexField) in
            alertTexField.placeholder = "Add a new category"
            textField = alertTexField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            
            if let name = textField.text, !name.isEmpty {
                let newCategory = Category(context: self.context)
                newCategory.name = name
                self.categoryArray.append(newCategory)
                DispatchQueue.main.async { self.tableView.reloadData() }
                self.saveCategories()
            }
        }
        
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - File Managment

extension CategoryViewController {
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {

        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}
