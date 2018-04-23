//
//  OriginViewController.swift
//  BackLog
//
//  Created by Dakota Kim on 4/9/18.
//  Copyright © 2018 theghost. All rights reserved.
//

import UIKit
import Firebase

class OriginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.performSegue(withIdentifier: "userLoggedIn", sender: self)
            } else {
                return
            }
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToRegistration", sender: self)
    }
}
