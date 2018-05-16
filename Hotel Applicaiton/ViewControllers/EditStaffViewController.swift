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

  
    @IBOutlet weak var foreNameInput: UITextField!
    @IBOutlet weak var sirNameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var postcodeInput: UITextField!
    
   
    
    
     var staffToUpdate = [Staff]()
    
    @IBOutlet weak var accountType: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        
        
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
            }
            
            
        }
        
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
    
    @objc func doneClicked(){
        self.view.endEditing(true)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func confirmAlert(){
        let successAlert = UIAlertController(title: "Account Updated", message: "Updated account information is now live", preferredStyle: UIAlertControllerStyle.alert)
        
        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "unwindEditAccount", sender: self)
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
            
            let db = Firestore.firestore()
            let staffType = accountType.titleForSegment(at: accountType.selectedSegmentIndex)
            let staff : [String : Any] = ["Forename" : foreNameInput.text!,
                                          "Sirname" : sirNameInput.text!,
                                          "Email" : emailInput.text!,
                                          "Address" : addressInput.text!,
                                          "Postcode" : postcodeInput.text!,
                                          "Phone" : phoneNumberInput.text!,
                                          "StaffType" : staffType!,
                                          "StaffID" : staffToUpdate[0].StaffID]
            
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
