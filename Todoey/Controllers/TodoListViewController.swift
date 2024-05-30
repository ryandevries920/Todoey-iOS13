//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
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
                    item.setValue(!item.done, forKey: "done")
                }
            } catch {
                print("Error \(error)")
            }
        }
//        let item = todoItems[indexPath.row]
//        
//        item.done = !item.done
//        
//        saveItems(Item)
        
        DispatchQueue.main.async { self.tableView.reloadData() }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Add new Item

extension TodoListViewController {
    
    func addTodoItem() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "New Item", message: nil, preferredStyle: .alert)
                alert.addTextField { (alertTextField) in
                    alertTextField.placeholder = "Add a new item"
                    textField = alertTextField
                }
                
                let action = UIAlertAction(title: "Add", style: .default) { [weak self] (action) in
                    if let title = textField.text, !title.isEmpty {
                        if let currentCategory = self?.selectedCategory {
                            do {
                                try self?.realm.write {
                                    let newItem = Item()
                                    newItem.title = title
                                    newItem.done = false
                                    currentCategory.items.append(newItem)
                                }
                            } catch {
                                print("Error saving new items, \(error)")
                            }
                            self?.tableView.reloadData()
                        }
                    }
                }
                
                alert.addAction(action)
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
        if let search = searchBar.text {
            let items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
            todoItems = items?.where {
                $0.title.contains(search, options: [.caseInsensitive, .diacriticInsensitive])
            }
        }
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
