//
//  ViewController.swift
//  BackLog
//
//  Created by Dakota Kim on 3/4/18.
//  Copyright © 2018 theghost. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {

    var todoTasks : Results<Task>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            //loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadItems()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        if let item = todoTasks?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none //Ternary operator
        } else {
            cell.textLabel?.text = "No Tasks Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoTasks?.count ?? 1
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done //Sets it to the opposite of what it currently is. HELLA SWIFTY.
//        context.delete(todoTasks[indexPath.row])
//        todoTasks.remove(at: indexPath.row)
        
        //saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new items to the list
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var taskDescription = UITextField()
        let alert = UIAlertController(title: "Add to BackLog", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Task", style: .default) { (action) in
            // what will happen once the user clicks the add task button on our alert.
        
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newTask = Task()
                        newTask.title = taskDescription.text!
                        currentCategory.tasks.append(newTask)
                    }
                } catch {
                    print("Error saving new task \(error)")
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create a new task"
            taskDescription = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func loadItems() {
        todoTasks = selectedCategory?.tasks.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    
}

//MARK: - Search bar methods

//extension TodoListViewController: UISearchBarDelegate {
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request : NSFetchRequest<Task> = Task.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        loadItems(with: request, predicate: predicate)
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            loadItems()
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//    }
//}

