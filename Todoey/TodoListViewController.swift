//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = ["Find Mike", "Find Eggos", "Destroy Demogorgon"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    //MARK: - Add new Item

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let addTodo = UIAlertController(title: "Enter ToDo Item", message: nil, preferredStyle: .alert)
        addTodo.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned addTodo] _ in
            if let answer = addTodo.textFields![0].text {
                self.itemArray.append(answer)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }

        addTodo.addAction(submitAction)

        present(addTodo, animated: true)
        
    }
    

}

//MARK: - UITavleViewDataSource Methods

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
}

//MARK: - UITableViewDelegate Methods

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}



