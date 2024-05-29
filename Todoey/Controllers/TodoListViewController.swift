//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        addTodoItem()
        
    }
    
    
}

//MARK: - UITavleViewDataSource Methods

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = itemArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate Methods

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = itemArray[indexPath.row]
        
        item.done = !item.done
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        saveItems()
        
        DispatchQueue.main.async { self.tableView.reloadData() }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Add new Item

extension TodoListViewController {
    
    func addTodoItem() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Enter ToDo Item", message: nil, preferredStyle: .alert)
        alert.addTextField { (alertTexField) in
            alertTexField.placeholder = "Create new Item"
            textField = alertTexField
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            
            if let title = textField.text, !title.isEmpty {
                let newItem = Item(context: self.context)
                newItem.title = title
                newItem.done = false
                self.itemArray.append(newItem)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.saveItems()
                }
            }
        }
        
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - File Managment

extension TodoListViewController {
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {

        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}

//MARK: - SearchBar Delegate methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request)
        DispatchQueue.main.async { searchBar.resignFirstResponder() }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async { searchBar.resignFirstResponder() }
            
        }
    }
}
