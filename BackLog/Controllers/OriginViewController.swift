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
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
    
    @IBAction func registerTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToRegistration", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
