//
//  CreateAccountViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 18/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {

    //UI Elements
    @IBOutlet weak var foreNameInput: UITextField!
    @IBOutlet weak var sirNameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var postcodeInput: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var inputStackVew: UIStackView!
    @IBOutlet weak var stackConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountType: UISegmentedControl!
    
    //Keyboard move boolean
    var moveStack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Keyborad tool bar setup
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([doneButton], animated: true)
        
        foreNameInput.inputAccessoryView = toolBar
        sirNameInput.inputAccessoryView = toolBar
        emailInput.inputAccessoryView = toolBar
        addressInput.inputAccessoryView = toolBar
        postcodeInput.inputAccessoryView = toolBar
        phoneNumberInput.inputAccessoryView = toolBar
        
        //Keyboard observer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomStackConstraint: NSLayoutConstraint!
    @objc func keyboardWillShow(notification: NSNotification) {
        //Move stack up
        if let info = notification.userInfo {
            let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            print("KEYBOARD ADJUST")
            
            self.view.layoutIfNeeded()
            if(moveStack){
                
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                    self.stackConstraint.constant -= 80
                    self.bottomStackConstraint.constant += 80
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //Move stack back to original
        if let info = notification.userInfo {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
                self.stackConstraint.constant = 15
                self.bottomStackConstraint.constant = 110
            }
        }
    }
    
    @objc func doneClicked(){
        self.view.endEditing(true)
    }
    
    @IBAction func phoneNumberEdit(_ sender: Any) {
        moveStack = true
    }
    
    @IBAction func postCodeEdit(_ sender: Any) {
        moveStack = true
    }
    @IBAction func addressEdit(_ sender: Any) {
        moveStack = false
    }
    @IBAction func emailEdit(_ sender: Any) {
        moveStack = false
    }
    @IBAction func sirNameEdt(_ sender: Any) {
        moveStack = false
    }
    @IBAction func fornemaeEdit(_ sender: Any) {
        moveStack = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBOutlet weak var createAccountButton: UIButton!
    @IBAction func createAccountTapped(_ sender: Any) {
        if (!checkLabels())
        {
            print("All fields need to be entered")
        } else {
            activityIndicator.startAnimating()
            createAccountButton.isEnabled = false
            
            //Create Account
            Auth.auth().createUser(withEmail: emailInput.text!, password: "changeme", completion: { (user, error) in
                
                if let err = error {
                    self.fireError(titleText: "Unable to change create user", lowerText: err.localizedDescription)
                    self.activityIndicator.stopAnimating()
                    self.createAccountButton.isEnabled = true
                } else {
                    print("Created account")
                    self.createAccount()
                }
            })
        }
    }
    
    func checkLabels( ) -> Bool{
        var isPass = true
        
        if(foreNameInput.text == ""){
            foreNameInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        } else {
            foreNameInput.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(foreNameInput.text?.isCharacter == false){
            foreNameInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            foreNameInput.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        
        if(sirNameInput.text == ""){
            sirNameInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            sirNameInput.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(sirNameInput.text?.isCharacter == false){
            sirNameInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            sirNameInput.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(emailInput.text == ""){
            emailInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            emailInput.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        
        if(addressInput.text == ""){
            addressInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            addressInput.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(postcodeInput.text == ""){
            isPass = false
        }else {
            postcodeInput.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(phoneNumberInput.text == "" || (phoneNumberInput.text?.isAlphaCharacter)!){
            phoneNumberInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            phoneNumberInput.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        
        if(isPass){
            return true
        } else {
            return false
        }
        
        
        
    }
    
    
    func createAccount()
    {
        if(checkLabels() == false)
        {
            self.activityIndicator.stopAnimating()
            self.createAccountButton.isEnabled = true
            print("Inputs incorrect")
        } else {
            let staffType = accountType.titleForSegment(at: accountType.selectedSegmentIndex)
            
            let userID = Auth.auth().currentUser?.uid
            
            let staff : [String : Any] = ["Forename" : foreNameInput.text!,
                                          "Sirname" : sirNameInput.text!,
                                          "Email" : emailInput.text!,
                                          "Address" : addressInput.text!,
                                          "Postcode" : postcodeInput.text!,
                                          "Phone" : phoneNumberInput.text!,
                                          "StaffType" : staffType!,
                                          "StaffID" : userID!]
            
            
            
            let db = Firestore.firestore()
            
            db.collection("Staff").document(userID!).setData(staff) { err in
                if let err = err {
                    print("Error adding staff document: \(err)")
                    self.fireError(titleText: "Error creating account", lowerText: err.localizedDescription)
                    self.activityIndicator.stopAnimating()
                    self.createAccountButton.isEnabled = true
                } else {
                    self.activityIndicator.stopAnimating()
                    self.createAccountButton.isEnabled = true
                    print("Staff added with ID: \(userID!)")
                    let successAlert = UIAlertController(title: "Staff Created", message: "Created a new account with email : " + self.emailInput.text!, preferredStyle: UIAlertControllerStyle.alert)
                    
                    successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        self.performSegue(withIdentifier: "unwindToManageStaff", sender: self)
                    }))
                    
                    
                    self.present(successAlert, animated: true, completion: nil)
                }
            }
        }
    }
}
