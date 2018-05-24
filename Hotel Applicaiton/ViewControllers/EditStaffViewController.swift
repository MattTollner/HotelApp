//
//  EditStaffViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 18/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase

extension String {
    var isAlphaN : Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
}
class EditStaffViewController: UIViewController {

    //UI Elements
    @IBOutlet weak var stackConstraint: NSLayoutConstraint!
    @IBOutlet weak var foreNameInput: UITextField!
    @IBOutlet weak var sirNameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var postcodeInput: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var accountType: UISegmentedControl!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    var moveStack = false
    
    let db = Firestore.firestore()
     var staffToUpdate = [Staff]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Keyboard observer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        
        //Populate fields
        if(!staffToUpdate.isEmpty)
        {
            foreNameInput.text = staffToUpdate[0].Forename
            sirNameInput.text = staffToUpdate[0].Sirname
            emailInput.text = staffToUpdate[0].Email
            addressInput.text = staffToUpdate[0].Address
            phoneNumberInput.text = staffToUpdate[0].Phone
            postcodeInput.text = staffToUpdate[0].Postcode
            
            if(staffToUpdate[0].StaffType == "Admin")
            {
                accountType.selectedSegmentIndex = 0
            }
            else if (staffToUpdate[0].StaffType == "Receptionist")
            {
                accountType.selectedSegmentIndex = 1
            }
            else if (staffToUpdate[0].StaffType == "Cleaner")
            {
                accountType.selectedSegmentIndex = 2
            } else {
                print("No staff type detected")
                fireError(titleText: "No staff detected", lowerText: "Please try again...")
                self.performSegue(withIdentifier: "unwindToManageStaff", sender: self)
                
            }
            
            
        }
        
        //Toolbar setup
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
    }
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
    
    //Close keyboard
    @objc func doneClicked(){
        self.view.endEditing(true)
    }
    
    @IBAction func fornameInputEdit(_ sender: Any) {
        moveStack = false
    }
    @IBAction func sirnameInputEdit(_ sender: Any) {
        moveStack = false
    }
    
    @IBAction func emailInputEdit(_ sender: Any) {
        moveStack = false
    }
    
    @IBAction func addressInputEdit(_ sender: Any) {
        moveStack = false
    }

    @IBAction func postcodeInputEdit(_ sender: Any) {
        moveStack = true
    }
    
    @IBAction func phoneNubmerEdit(_ sender: Any) {
        moveStack = true
    }
    @IBAction func deleteButtonTapped(_ sender: Any) {
        deleteStaff()
    }
    
    
    func deleteStaff(){
        
        
        let delAlert = UIAlertController(title: "Delete Staff", message: "Are you sure you want to delete the staff account?", preferredStyle: UIAlertControllerStyle.alert)
        delAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.activityIndicator.startAnimating()
            self.mainStackView.isHidden = true
            self.deleteButton.isEnabled = false
            self.updateButton.isEnabled = false
            
            //Delete from firebase
            self.db.collection("Staff").document(self.staffToUpdate[0].StaffID).delete() { err in
                if let err = err {
                    print("Error removing staff document: \(err)")
                    self.activityIndicator.stopAnimating()
                    self.mainStackView.isHidden = false
                    self.deleteButton.isEnabled = true
                    self.updateButton.isEnabled = true
                    
                    self.fireError(titleText: "Error deleting staff!", lowerText: err.localizedDescription)
                } else {
                    self.activityIndicator.stopAnimating()
                    self.mainStackView.isHidden = false
                    self.deleteButton.isEnabled = true
                    self.updateButton.isEnabled = true
                    self.delAlert()
                }
            }
        }))
        
        delAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            self.deleteButton.isEnabled = true
            self.updateButton.isEnabled = true
            self.activityIndicator.stopAnimating()
            self.mainStackView.isHidden = false
            
        }))
        self.present(delAlert, animated: true, completion: nil)
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
        if(phoneNumberInput.text == "" || (phoneNumberInput.text?.isCharacter)!){
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func confirmAlert(){
        let successAlert = UIAlertController(title: "Account Updated", message: "Updated account information is now live", preferredStyle: UIAlertControllerStyle.alert)
        
        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "unwindToManageStaff", sender: self)
        }))
        self.present(successAlert, animated: true, completion: nil)
    }
    
    func delAlert(){
        let successAlert = UIAlertController(title: "Account Deleted", message: "Deleted account from database", preferredStyle: UIAlertControllerStyle.alert)
        
        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "unwindToManageStaff", sender: self)
        }))
        self.present(successAlert, animated: true, completion: nil)
    }
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
  
    @IBAction func updateAccountTapped(_ sender: Any) {
        if (checkLabels() == false)
        {
            print("All fields need to be entered")
        } else {
            //Create dict
            let staffType = accountType.titleForSegment(at: accountType.selectedSegmentIndex)
            let staff : [String : Any] = ["Forename" : foreNameInput.text!,
                                          "Sirname" : sirNameInput.text!,
                                          "Email" : emailInput.text!,
                                          "Address" : addressInput.text!,
                                          "Postcode" : postcodeInput.text!,
                                          "Phone" : phoneNumberInput.text!,
                                          "StaffType" : staffType!,
                                          "StaffID" : staffToUpdate[0].StaffID]
            
            //Update firebase document
            db.collection("Staff").document(staffToUpdate[0].StaffID).setData(staff) { (error) in
                if let error = error {
                    print("Error updating staff document: \(error)")
                    self.fireError(titleText: "Error updating staff", lowerText: error.localizedDescription)
                } else {
                    print("Document updated stored id: \(self.staffToUpdate[0].StaffID)")
                    self.confirmAlert()
                }
            }
            
        }
    }
   
  
    
    

}
