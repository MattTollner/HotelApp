//
//  ViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 09/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: true)
        emailTextField.inputAccessoryView = toolBar
        passwordTextField.inputAccessoryView = toolBar
        
        
       // docRef = Firestore.firestore().collection("Rooms")
        //ref = db.collection
        
        print("view did load")
    }
    
    @objc func doneClicked(){
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideElements(value : Bool){
        if(!value){
            emailTextField.isHidden = false
            passwordTextField.isHidden = false
            forgotPasswordButton.isHidden = false
            signInButton.isHidden = false
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        } else {
            emailTextField.isHidden = true
            passwordTextField.isHidden = true
            forgotPasswordButton.isHidden = true
            signInButton.isHidden = true
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        }
        
    }
    
    @IBAction func unwindToLogin(segue:UIStoryboardSegue) {
        print("Unwind to login")
        
    }

    
    func checkInputs() -> Bool {
        let whitespaceSet = CharacterSet.whitespaces

        var valid = false
        
        self.view.endEditing(true)
      
        if let email = emailTextField.text {
            if(email.trimmingCharacters(in: whitespaceSet).isEmpty){
                print("email only contains whte space")
                valid = false
            } else {
                print("email valid")
                valid = true
            }
        } else {
            print("Invalid Email Call")
            valid = false
        }
        
        if passwordTextField.text != nil {
            print("Pass Valid")
            valid = true
        } else {
            print("Invalid pass Call")
            valid = false
        }
        
        return valid
    }
    
    
   
    
    @IBAction func signInButton(_ sender: Any) {
        
        if(!self.checkInputs()){
            print("input not valid")
        } else {
            hideElements(value: true)
            let db = Firestore.firestore()
            if let email = emailTextField.text, let password = passwordTextField.text
            {
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if let firebaseError = error {
                        print(firebaseError.localizedDescription)
                        print("Hello")
                        self.hideElements(value: false)
                        let alert = UIAlertController(title: "Incorrect Email or Password", message: firebaseError.localizedDescription, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        return
                    } else {
                        print("Success Logged In!")
                        self.hideElements(value: false)
                        self.storeSignInDetails()
                        self.performSegue(withIdentifier: "toStaffHome", sender: self)
                    }
                    
                })
            } else {
                print("Inputs invalid")
            }
        }
    }
    
    func storeSignInDetails(){
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser?.uid
        print("USER ID " + userID!)
        
        db.collection("Staff").document(userID!).getDocument { (snapshot, error) in
            if let error = error {
                print("Error getting staff documents : \(error)")
            } else
            {
                
                print("Populating global singletons")
                let staff = Staff(dictionary: snapshot?.data()! as! [String : AnyObject])
                //Sets global Singleton vars
                let userID = Auth.auth().currentUser?.uid
                HelperClass.userTypeRefernce.userID = userID!
                HelperClass.userTypeRefernce.userType = staff.StaffType
                print("UID " + HelperClass.userTypeRefernce.userID)
                print("U TYPE " + HelperClass.userTypeRefernce.userType)
                self.performSegue(withIdentifier: "toStaffHome", sender: self)
                
            }
        }
        
      
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "Reset password?", message: "Enter account email address", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = "Email Address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        let resetFailedAlert = UIAlertController(title: "Reset Failed", message: error.localizedDescription, preferredStyle: .alert)
                        resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetFailedAlert, animated: true, completion: nil)
                    } else {
                        let resetEmailSentAlert = UIAlertController(title: "Email sent successfully", message: "Check your email, dont forget spamß", preferredStyle: .alert)
                        resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetEmailSentAlert, animated: true, completion: nil)
                    }
                }
            })
        }))
        //PRESENT ALERT
        self.present(forgotPasswordAlert, animated: true, completion: nil)    }
    
    
}

