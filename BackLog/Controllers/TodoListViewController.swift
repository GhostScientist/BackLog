//
//  ViewController.swift
//  BackLog
//
//  Created by Dakota Kim on 3/4/18.
//  Copyright © 2018 theghost. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Task]()

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newTask = Task()
        newTask.title = "Find Mike"
        itemArray.append(newTask)
        
        let newTask2 = Task()
        newTask2.title = "Buy Eggos"
        itemArray.append(newTask2)
        
        let newTask3 = Task()
        newTask3.title = "Destroy Demogorgon"
        itemArray.append(newTask3)
        
        if let items = defaults.array(forKey: "TodoListArray") as? [Task] {
         itemArray = items
         }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none //Ternary operator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done //Sets it to the opposite of what it currently is. HELLA SWIFTY.
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new items to the list
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var taskDescription = UITextField()
        let alert = UIAlertController(title: "Add to BackLog", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Task", style: .default) { (action) in
            // what will happen once the user clicks the add task button on our alert.
            let newTask = Task()
            newTask.title = taskDescription.text!
            self.itemArray.append(newTask)
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create a new task"
            taskDescription = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
}

