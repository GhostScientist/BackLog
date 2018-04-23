//
//  ViewController.swift
//  BackLog
//
//  Created by Dakota Kim on 3/4/18.
//  Copyright © 2018 theghost. All rights reserved.
//
import UIKit
import ChameleonFramework
import Firebase

class TodoListViewController: SwipeTableViewController {
    
    var taskTrackerArray = [Task]()
    var selectedCategory : Category? {
        didSet{
            //loadItems()
        }
    }
    
    //MARK: - Firebase Stuff
    let currentUserID = Auth.auth().currentUser?.uid
    let database = Firestore.firestore()
    var currentUser: User?
    var docRef: DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        let parentColor = UIColor(hexString: (self.selectedCategory?.categoryColor)!)
        tableView.backgroundColor = parentColor?.lighten(byPercentage: CGFloat(0.5))
        currentUser = Auth.auth().currentUser
        let database = Firestore.firestore()
        print("Loading tasks from Firebase...")
        loadTasksFromFirebase()
        print("Reloading data...")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // This function sets the title of the Nav controller to the name of the category selected.
        // It sets the color of the navBar to the same color as the selected category.
        title = selectedCategory?.categoryName
        guard let colorHex = selectedCategory?.categoryColor else {fatalError()}
        updateNavBar(withHexCode: colorHex)
        self.tableView.reloadData()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        // This updates the Navbar to the default color when returning to the CategoryViewController.
        guard let navBar = navigationController?.navigationBar else {fatalError("Nav Controller Does not exist.")}
        guard let navBarColor = UIColor(hexString: "0DFF8F") else {fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        // Updates the navigation bar's background and text with a consistent color scheme.
        guard let navBar = navigationController?.navigationBar else {fatalError("Nav Controller Does not exist.")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
    }
    
    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if taskTrackerArray.count > 0 {
            let item = taskTrackerArray[indexPath.row]
            cell.textLabel?.text = item.title
            let parentColor = UIColor(hexString: (self.selectedCategory?.categoryColor)!)
            let color = parentColor?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(taskTrackerArray.count + 10))
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color!, returnFlat: true)
            cell.tintColor = UIColor.white
            cell.accessoryType = item.done ? .checkmark : .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskTrackerArray.count
    }
    
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // This function changes the done property of a task object to its inverse value.
        let task = taskTrackerArray[indexPath.row]
        task.done = !task.done
        let taskRef = database.collection((currentUser?.uid)!).document((selectedCategory?.categoryName)!)
            .collection("tasks").document(task.title)
        taskRef.updateData(["done" : task.done]) { (error) in
            if let error = error {
                print("There was an error updating the done status of this task. \(error)")
            } else {
                print("Task's done status successfully updated.")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new items to the list
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // This function should add the newly created task to both Firestore and the Task array
        var taskDescription = UITextField()
        let alert = UIAlertController(title: "Add to BackLog", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Task", style: .default) { (action) in
            // what will happen once the user clicks the add task button on our alert.
            
            let currentCategory = self.selectedCategory
            let newFBTask = Task()
            if taskDescription.text != "" {
                newFBTask.title = taskDescription.text!
            } else {
                newFBTask.title = "No Task Title"
            }
            newFBTask.dateCreated = Date()
            newFBTask.parent = (self.selectedCategory?.categoryName)!
            newFBTask.parentColor = (self.selectedCategory?.categoryColor)!
            self.taskTrackerArray.append(newFBTask)
            self.saveData(categoryToBeSavedUnder: (self.selectedCategory?.categoryName)!, taskToBeSaved: newFBTask)
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create a new task"
            taskDescription = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true) {
            print(self.taskTrackerArray)
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        // This function handles the deletion of tasks.
        let taskForDeletionFB = taskTrackerArray[indexPath.row]
        deleteDataFromFirebase(taskForDeletion: taskForDeletionFB)
        taskTrackerArray.remove(at: indexPath.row)
    }
    
    func clearCheckedTasks() {
        // Iterates over the array of tasks and removes any tasks with a 'true' value for the done property.
        let range = taskTrackerArray.count
        if range > 0 {
            for trackedTask in taskTrackerArray {
                if trackedTask.done == true {
                    let x = database.collection((currentUser?.uid)!).document((selectedCategory?.categoryName)!)
                        .collection("tasks").document(trackedTask.title)
                    x.delete(completion: { (error) in
                        if let error = error {
                            print("There was an error removing the task from the database. \(error)")
                        }
                        else {
                            print("All's good")
                        }
                    })
                    taskTrackerArray.remove(at: taskTrackerArray.index(of: trackedTask)!)
                }
            }
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        // This allows for a "Shake to Clear" functionality.
        print("Motion Detected")
        clearCheckedTasks()
        tableView.reloadData()
    }
    
    //MARK: Firebase Methods
    
    func saveData(categoryToBeSavedUnder: String, taskToBeSaved: Task) {
        // A compact function to easily save data to Firestore at a specified location.
        docRef = database.collection(currentUserID!).document(categoryToBeSavedUnder)
            .collection("tasks").document(taskToBeSaved.title)
        docRef.setData(taskToBeSaved.returnDict()) { (error) in
            if let error = error {
                print ("There was an error, \(error.localizedDescription)")
            } else {
                print("Data has been saved")
            }
        }
    }
    
    func deleteDataFromFirebase(taskForDeletion: Task) {
        let taskForDeletionDocRef = database.collection(currentUserID!).document((selectedCategory?.categoryName)!)
            .collection("tasks").document(taskForDeletion.title)
        taskForDeletionDocRef.delete { (error) in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func loadTasksFromFirebase() {
        let taskCollectionRef = database.collection(currentUserID!).document((selectedCategory?.categoryName)!)
            .collection("tasks").order(by: "name")
        taskCollectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("ERROR OH FUCK NO: \(error)")
            } else {
                for document in snapshot!.documents {
                    let myDoc = document.data()
                    let myTempTask = Task()
                    myTempTask.title = myDoc["name"] as! String
                    myTempTask.dateCreated = myDoc["dateCreated"] as! Date
                    myTempTask.parent = myDoc["parent"] as! String
                    myTempTask.parentColor = myDoc["parentColor"] as! String
                    myTempTask.done = myDoc["done"] as! Bool
                    self.taskTrackerArray.append(myTempTask)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            //self.tableView.performSelector(onMainThread: "reloadData", with: nil, waitUntilDone: true)
        }
        print(taskTrackerArray)
    }
}
