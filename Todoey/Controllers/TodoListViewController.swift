//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = Item(title: "Find Mike")
        itemArray.append(newItem)
        
        let newItem2 = Item(title: "Find Eggos")
        itemArray.append(newItem2)
        
        let newItem3 = Item(title: "Destroy Demogorgon")
        itemArray.append(newItem3)
        
        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemArray = items
        }
        
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
                let newItem = Item(title: title)
                self.itemArray.append(newItem)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.defaults.set(self.itemArray, forKey: "TodoListArray")
                }
            }
        }
        
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
}
