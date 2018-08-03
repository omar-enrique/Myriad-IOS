//
//  ViewController.swift
//  Myriad
//
//  Created by Omar Finol-Evans on 7/22/18.
//  Copyright © 2018 Omar Finol-Evans. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    var signUpViewActive = true
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated:true, completion:nil)
    }
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBAction func signUpClicked(_ sender: Any) {
        if email.text == "" || password.text == "" {
            self.displayAlert(title: "Error in form", message: "Please enter an email and password")
        } else {
            if(signUpViewActive) {
                print("Signing up")
                var user = PFUser()
                user.username = email.text
                user.password = password.text
                user.email = email.text
                
                user.signUpInBackground(block: { (success, error) in
                    if let error = error {
                        self.displayAlert(title: "Could not sign you up", message: error.localizedDescription)
                    } else {
                        print("Signed up!")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                })
            } else {
                PFUser.logInWithUsername(inBackground: email.text!, password: password.text!, block: { (user, error) in
                    if user != nil {
                        print ("Login successful")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    } else {
                        var errorText = "Unknown error: please try again"
                        if let error = error {
                            errorText = error.localizedDescription
                        }
                        self.displayAlert(title: "Could not log you in", message: errorText)
                    }
                })
            }
        }
    }
    @IBOutlet var signUPButton: UIButton!
    
    @IBOutlet var logInButton: UIButton!
    
    @IBAction func logInClicked(_ sender: Any) {
        if (signUpViewActive) {
            signUpViewActive = false
            signUPButton.setTitle("Log In", for: [])
            logInButton.setTitle("Sign Up", for: [])
        } else {
            signUpViewActive = true
            signUPButton.setTitle("Sign Up", for:[])
            logInButton.setTitle("Log In", for: [])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            self.performSegue(withIdentifier: "showUserTable", sender: self)
        }
        
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

