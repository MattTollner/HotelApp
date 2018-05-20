//
//  EditStaffViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 18/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase


class UpdateAccountViewController: UIViewController {
    
    
    @IBOutlet weak var stackConstraint: NSLayoutConstraint!
    @IBOutlet weak var foreNameInput: UITextField!
    @IBOutlet weak var sirNameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var postcodeInput: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var accountTypeLabel: UILabel!
    
    var moveStack = false
    var staff : Staff?
    
    let db = Firestore.firestore()
    var staffToUpdate = [Staff]()
    
    @IBOutlet weak var accountType: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //Keyboard observer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        getStaff()
        
        
        
        //Tool bar setup
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            print("KEYBOARD ADJUST")
            
            self.view.layoutIfNeeded()
            if(moveStack){
                
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                    self.stackConstraint.constant = -35
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let info = notification.userInfo {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
                self.stackConstraint.constant = 15
            }
        }
    }
    
    
    
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
    
    @IBOutlet weak var mainStackView: UIStackView!
    func deleteStaff(){
        
        let delAlert = UIAlertController(title: "Delete Staff", message: "Are you sure you want to delete the staff account?", preferredStyle: UIAlertControllerStyle.alert)
        delAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.activityIndicator.startAnimating()
            self.mainStackView.isHidden = true
            self.db.collection("Staff").document(self.staffToUpdate[0].StaffID).delete() { err in
                if let err = err {
                    print("Error removing staff document: \(err)")
                    self.activityIndicator.stopAnimating()
                    self.mainStackView.isHidden = false
                    self.fireError(titleText: "Error deleting staff!", lowerText: err.localizedDescription)
                } else {
                    self.activityIndicator.stopAnimating()
                    self.mainStackView.isHidden = false
                    self.confirmAlert()
                    
                }
            }
        }))
        
        delAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
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
        if(foreNameInput.text?.isAlpha == false){
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
        if(sirNameInput.text?.isAlpha == false){
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
            return false
        }else {
            phoneNumberInput.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        
        if(isPass){
            return true
        } else {
            return false
        }
        
        
        
    }
    
    
    func getStaff(){
        mainStackView.isHidden = true
        updateButton.isHidden = true
        activityIndicator.startAnimating()
        
        let staffID = HelperClass.userTypeRefernce.userID
        
        if staffID != "nil"{
            let docRef = db.collection("Staff").document(staffID)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.staff = Staff(dictionary: document.data() as! [String : AnyObject])
                    print("Staff EMAIL " + (self.staff?.Email)!)
                    self.populateFields()
                } else {
                    print("Document does not exist")
                    self.activityIndicator.stopAnimating()
                    self.mainStackView.isHidden = false
                    self.updateButton.isHidden = false
                    self.failAlert()
                }
            }
        } else {
            //fireError(titleText: "No account logged in", lowerText: "Please try login again")
            activityIndicator.stopAnimating()
            mainStackView.isHidden = false
            updateButton.isHidden = false
            failAlert()
            
            
        }
        
        
    }
    
    func failAlert(){
        let failAlert = UIAlertController(title: "No Account Detected", message: "Please try login again", preferredStyle: UIAlertControllerStyle.alert)
        
        failAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        }))
        
        
        self.present(failAlert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var updateButton: UIButton!
    func populateFields(){
        activityIndicator.stopAnimating()
        mainStackView.isHidden = false
        updateButton.isHidden = false
        print("Populating input fields : " + (staff?.Email)!)
        if let staff = staff {
            print("Updateing fields")
            foreNameInput.text = staff.Forename
            sirNameInput.text = staff.Sirname
            emailInput.text = staff.Email
            addressInput.text = staff.Address
            postcodeInput.text = staff.Postcode
            phoneNumberInput.text = staff.Phone
            accountTypeLabel.text = staff.StaffType
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func confirmAlert(){
        let successAlert = UIAlertController(title: "Account Updated", message: "Updated account information is now live", preferredStyle: UIAlertControllerStyle.alert)
        
        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "unwindToStaffHome", sender: self)
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
            
            if let newStaff = staff {
                
                
                
                
                let staff : [String : Any] = ["Forename" : foreNameInput.text!,
                                              "Sirname" : sirNameInput.text!,
                                              "Email" : emailInput.text!,
                                              "Address" : addressInput.text!,
                                              "Postcode" : postcodeInput.text!,
                                              "Phone" : phoneNumberInput.text!,
                                              "StaffType" : newStaff.StaffType,
                                              "StaffID" : newStaff.StaffID]
                
                db.collection("Staff").document(newStaff.StaffID).setData(staff) { (error) in
                    if let error = error {
                        print("Error updating staff document: \(error)")
                        self.fireError(titleText: "Error updating staff", lowerText: error.localizedDescription)
                    } else {
                        
                        self.confirmAlert()
                    }
                }
                
            }
        }
    }
}
