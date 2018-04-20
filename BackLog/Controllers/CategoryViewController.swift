//
//  CategoryViewController.swift
//  BackLog
//
//  Created by Dakota Kim on 3/10/18.
//  Copyright © 2018 theghost. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class CategoryViewController: SwipeTableViewController{

    var categoryFirebaseArray = [Category?]()
    
    var database : DocumentReference!
    let currentUserID = Auth.auth().currentUser?.uid
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .default) { (action) in
            return
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "userLoggedOut", sender: self)
            } catch {
                print("There was an error logging out. \(error)")
            }
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategoriesFromFirebase()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        let navBarColor = UIColor(hexString: "0DFF8F")
        let navBar = navigationController?.navigationBar
        tableView.backgroundColor = UIColor(hexString: "7BFFA9")
        navBar?.barTintColor = navBarColor
        navBar?.tintColor = ContrastColorOf(navBarColor!, returnFlat: true)
        navBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor!, returnFlat: true)]
        navBar?.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor!, returnFlat: true)]
        self.navigationItem.hidesBackButton = true
    }

    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        //print("index path is \(indexPath.row)")
        if categoryFirebaseArray.count > 0 {
            cell.textLabel?.text = categoryFirebaseArray[indexPath.row]?.categoryName ?? "No categories added"
            let categoryHex = categoryFirebaseArray[indexPath.row]?.categoryColor ?? "0DFF8F"
            cell.backgroundColor = UIColor(hexString: categoryHex)
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: categoryHex)!, returnFlat: true)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryFirebaseArray.count
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //This will control what happens when a user selects a category. It should initiate a segue
        //into the respective list of tasks. (Example: if a user taps a list for their shopping tasks,
        //it should take them to their list of shopping tasks. This will be implemented later.
        performSegue(withIdentifier: "goToTasks", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTasks" {
            let destinationVC = segue.destination as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoryFirebaseArray[indexPath.row]
            }
        }
        if segue.identifier == "userLoggedOut" {
            return
        }
    }

    
    //MARK: - Data Manipulation Methods
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var categoryDescription = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category()
            newCategory.categoryColor = UIColor.randomFlat.hexValue()
            newCategory.categoryName = categoryDescription.text! // Force unwraps. We can optionally bind later to be swiftier.
            self.save(category: newCategory)
        }
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new category"
            categoryDescription = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func save(category: Category) {
        Firestore.firestore().collection(currentUserID!).document(category.categoryName).setData(category.returnDict())
        categoryFirebaseArray.append(category)
        self.tableView.reloadData()
    }

    func loadCategoriesFromFirebase() {
        let categoryCollectionRef = Firestore.firestore().collection(currentUserID!).order(by: "name")
        categoryCollectionRef.getDocuments{ (snapshot, error) in
            if let error = error {
                print("Error getting document. \(error)")
            } else {
                if let snapshotCount = snapshot?.documents.count, snapshotCount > 0 {
                    for document in snapshot!.documents {
                        let myDoc = document.data()
                        let myTempCategory = Category()
                        myTempCategory.categoryName = myDoc["name"] as! String
                        myTempCategory.categoryColor = myDoc ["color"] as! String
                        self.categoryFirebaseArray.append(myTempCategory)
                    }
                    //self.tableView.reloadData()
                    print(self.categoryFirebaseArray)
                } else {
                    print("Database is empty.")
                }
            }
            self.tableView.performSelector(onMainThread: "reloadData", with: nil, waitUntilDone: true)
        }
    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        print("Deleting the category at index: \(indexPath.row)")
        let categoryForDeletion = categoryFirebaseArray[indexPath.row]
        print("Deleting the category named: \(categoryForDeletion?.categoryName)")
        Firestore.firestore().collection(currentUserID!).document((categoryForDeletion?.categoryName)!).delete { (error) in
            if error == nil {
                print("Category deleted successfully.")
            } else {
                print("Oops! There was an error. \(error)")
            }
        }
        categoryFirebaseArray.remove(at: indexPath.row)
    }
}




