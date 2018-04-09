//
//  ViewController.swift
//  BackLog
//
//  Created by Dakota Kim on 3/4/18.
//  Copyright © 2018 theghost. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import Firebase

class TodoListViewController: SwipeTableViewController {

    var todoTasks : Results<Task>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            //loadItems()
        }
    }
    
    let database = Firestore.firestore()
    var docRef: DocumentReference!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    func saveTestData(categoryToBeSavedUnder: String, taskToBeSaved: Task) {
        docRef = Firestore.firestore().collection(categoryToBeSavedUnder).document(taskToBeSaved.title)
        docRef.setData(taskToBeSaved.returnDict()) { (error) in
            if let error = error {
                print ("There was an error, \(error.localizedDescription)")
            } else {
                print("Data has been saved")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        loadItems()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.categoryName
        guard let colorHex = selectedCategory?.categoryColor else {fatalError()}
        updateNavBar(withHexCode: colorHex)
    }
    
   override func willMove(toParentViewController parent: UIViewController?) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Nav Controller Does not exist.")}
        guard let navBarColor = UIColor(hexString: "0DFF8F") else {fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Nav Controller Does not exist.")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }

    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoTasks?[indexPath.row]{
            let parentColor = UIColor(hexString: (self.selectedCategory?.categoryColor)!)
            cell.textLabel?.text = item.title
            if let color = parentColor?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoTasks!.count + 10)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            cell.tintColor = UIColor.white
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
        if let item = todoTasks?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("error saving done status, \(error)")
            }
            
        }
        tableView.reloadData()
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
                    let newFBTask = Task()
                    newFBTask.title = taskDescription.text!
                    newFBTask.dateCreated = Date()
                    newFBTask.parent = (self.selectedCategory?.categoryName)!
                    newFBTask.parentColor = (self.selectedCategory?.categoryColor)!
                    try self.realm.write {
                        let newTask = Task()
                        newTask.title = taskDescription.text!
                        newTask.dateCreated = Date()
                        currentCategory.tasks.append(newTask)
                    }
                    self.saveTestData(categoryToBeSavedUnder: newFBTask.parent, taskToBeSaved: newFBTask)
                } catch {
                    print("Error saving new task \(error)")
                }
            }
            self.tableView.reloadData()
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
    
    override func updateModel(at indexPath: IndexPath) {
        if let taskForDeletion = todoTasks?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(taskForDeletion)
                }
            } catch {
                print("Error deleting task. \(error)")
            }
        }
    }
    
    func clearCheckedTasks() {
        guard let range = todoTasks?.count else {fatalError("Could not access count")}
        if range > 0 {
            for task in todoTasks! {
                if task.done == true {
                    do {
                        try realm.write {
                            realm.delete(task)
                        }
                    } catch {
                        print("Could not clear task.\(error)")
                    }
                }
            }
            
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        print("Motion Detected")
        clearCheckedTasks()
        tableView.reloadData()
    }
}


//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoTasks = todoTasks?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

