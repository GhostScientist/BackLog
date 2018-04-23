//
//  RegistrationViewController.swift
//  BackLog
//
//  Created by Dakota Kim on 4/9/18.
//  Copyright © 2018 theghost. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error == nil {
                print("User successfully created.")
            } else {
                print("Error registering user. \(error)")
            }
        }
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error == nil {
                print("User logging in")
                self.performSegue(withIdentifier: "registrationSuccess", sender: self)
            }
        }
    }
}
