//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class TodoListViewController: UITableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        addTodoItem()
        
    }
    
    
}

//MARK: - UITavleViewDataSource Methods

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
}

//MARK: - UITableViewDelegate Methods

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error \(error)")
            }
        }
        
        DispatchQueue.main.async { self.tableView.reloadData() }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Add new Item

extension TodoListViewController {
    
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
    
    func addTodoItem() {
        openWindow(title: "Add Item", placeholder: "New item to add", action: "Add") { newName in
            if let title = newName, !title.isEmpty {
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            guard let newItem = Item(as: title) else {
                                self.showErrorAlert(message: "Invalid item title.")
                                return
                            }
                            currentCategory.items.append(newItem)
                        }
                        self.tableView.reloadData()
                    } catch {
                        self.showErrorAlert(message: "Error saving new item: \(error.localizedDescription)")
                    }
                }
            } else {
                self.showErrorAlert(message: "Item title cannot be empty.")
            }
        }
    }
    
    func editItem(item: Item?) {
        openWindow(title: "String", placeholder: "String", action: "Save", initialValue: item!.title) { newName in
            if let title = newName, !title.isEmpty {
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            item?.title = title
                        }
                        self.tableView.reloadData()
                    } catch {
                        self.showErrorAlert(message: "Error saving new item: \(error.localizedDescription)")
                    }
                }
            } else {
                self.showErrorAlert(message: "Item title cannot be empty.")
            }
        }
        
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - File Managment

extension TodoListViewController {
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}

//MARK: - SearchBar Delegate methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        DispatchQueue.main.async { self.tableView.reloadData() }
        DispatchQueue.main.async { searchBar.resignFirstResponder() }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async { searchBar.resignFirstResponder() }
            
        }
    }
}

//MARK: - Swipekit methods

extension TodoListViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in

            if let item = self.todoItems?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(item)
                    }
                } catch {
                    print("Error \(error)")
                }
            }
            self.tableView.reloadData()
        }

        deleteAction.image = UIImage(named: "delete")
        
        let editAction = SwipeAction(style: .default, title: "Edit") { [self] action, indexPath in
            self.editItem(item: todoItems?[indexPath.row])
        }

        return [deleteAction, editAction]
    }
    
}
