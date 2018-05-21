//
//  HotelInfoViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 26/04/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase 
class HotelInfoViewController: UIViewController {

    
   
    @IBOutlet weak var addressInput: UITextView!
    
    @IBOutlet weak var breakfastPeriod: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var checkInInput: UITextField!
    @IBOutlet weak var phoneInput: UITextField!
    
    @IBOutlet weak var topStackConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var detailStack: UIStackView!
    let db = Firestore.firestore()
    var info : HotelInfo?
   
    var moveKeyBoard = false
    let docId = "R2Q0AM8B4G88twCy12ZG"
 
    
    @IBOutlet weak var checkOutInput: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        detailStack.isHidden = true
        updateButton.isHidden = true
        getInfo()
        // Do any additional setup after loading the view.
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        
        toolBar.setItems([doneButton], animated: true)
        
        addressInput.inputAccessoryView = toolBar
        emailInput.inputAccessoryView = toolBar
        breakfastPeriod.inputAccessoryView = toolBar
        checkInInput.inputAccessoryView = toolBar
        checkOutInput.inputAccessoryView = toolBar
        phoneInput.inputAccessoryView = toolBar
        
        //Keyboard observer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if moveKeyBoard{
            if let info = notification.userInfo {
                let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
                print("KEYBOARD ADJUST")
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                    self.stackConstraint.constant = (rect.height)
                    self.topStackConstraint.constant -= (rect.height)
                }
            }
        } else{
            print("Bool False")
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        moveKeyBoard = false
        if let info = notification.userInfo {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
                self.stackConstraint.constant = 30
                self.topStackConstraint.constant = 13
            }
        }
    }
    
    
    @objc func doneClicked(){
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var updateButton: UIButton!
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    @IBAction func phoneInputEdit(_ sender: Any) {
        print("Phone Editing")
        moveKeyBoard = true
    }
    @IBAction func checkOutInput(_ sender: Any) {
        moveKeyBoard = true
    }
    @IBAction func checkInInput(_ sender: Any) {
        moveKeyBoard = true
    }
    @IBAction func hotelEmailInput(_ sender: Any) {
        moveKeyBoard = false
    }
    @IBAction func breakfastInputEdit(_ sender: Any) {
        moveKeyBoard = false
    }
    
    func getInfo(){
        let docRef = db.collection("HotelInfo").document(docId)
        docRef.getDocument { (document, error) in
            if let error = error {
                self.fireError(titleText: "Error fetching hotel information", lowerText: error.localizedDescription)
            }else {
            
                if let document = document, document.exists {
                    self.info = HotelInfo(dictionary: document.data() as! [String : AnyObject])
                    self.populateInfo()
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func populateInfo(){
        detailStack.isHidden = false
        updateButton.isHidden = false
        if let data = self.info {
            addressInput.text = data.Address
            breakfastPeriod.text = data.Breakfast
            emailInput.text = data.Email
            checkInInput.text = data.CheckIn
            checkOutInput.text = data.CheckOut
            phoneInput.text = data.Phone
            detailStack.isHidden = false
            updateButton.isHidden = false
        }
    }
    
    
    
    @IBAction func updatePressed(_ sender: Any) {
        
        
        if checkLabels() {
            info?.Address = addressInput.text
            info?.Breakfast = breakfastPeriod.text!
            info?.CheckIn = checkInInput.text!
            info?.CheckOut = checkOutInput.text!
            info?.Email = emailInput.text!
            info?.Phone = phoneInput.text!
            
            let dictInfo = info?.getDict()
            
            
            if let dInfo = dictInfo {
                let db = Firestore.firestore()
                db.collection("HotelInfo").document(docId).setData(dInfo) { (error) in
                    if let error = error {
                        print("Error updating info document: \(error)")
                        self.fireError(titleText: "Error updating hotel information", lowerText: error.localizedDescription)
                    } else {
                        print("Document updated")
                       self.confirmAlert()
                        
                    }
                }
            }
        }

    }
    
    func confirmAlert(){
        let successAlert = UIAlertController(title: "Hotel Updated", message: "Updated hotel information is now live", preferredStyle: UIAlertControllerStyle.alert)
        
        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "unwindEditInfo", sender: self)
        }))
        
        
        self.present(successAlert, animated: true, completion: nil)
    }
    
    func checkLabels( ) -> Bool{
        var isPass = true
        emailInput.text  = emailInput.text?.replacingOccurrences(of: " ", with: "")
        phoneInput.text  = phoneInput.text?.replacingOccurrences(of: " ", with: "")
      
        
        if(addressInput.text == "" || addressInput.text == nil){
            addressInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.2189437212, blue: 0.1137813288, alpha: 0.548965669)
            isPass = false
        } else {
            addressInput.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if(breakfastPeriod.text == ""){
            breakfastPeriod.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.2189437212, blue: 0.1137813288, alpha: 0.548965669)
            isPass = false
        }else {
            breakfastPeriod.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if(emailInput.text == ""){
            emailInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.2189437212, blue: 0.1137813288, alpha: 0.548965669)
            isPass = false
        }else {
            emailInput.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if(checkOutInput.text == ""){
            checkOutInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.2189437212, blue: 0.1137813288, alpha: 0.548965669)
            isPass = false
        }else {
            checkOutInput.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        if(checkInInput.text == ""){
            checkInInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.2189437212, blue: 0.1137813288, alpha: 0.548965669)
            isPass = false
        }else {
            checkInInput.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        
        if(addressInput.text == ""){
            addressInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.2189437212, blue: 0.1137813288, alpha: 0.548965669)
            isPass = false
        }else {
            addressInput.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if(phoneInput.text == "" || (phoneInput.text?.isAlphaCharacter)!){
            phoneInput.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.2189437212, blue: 0.1137813288, alpha: 0.548965669)
            isPass =  false
        }else {
            phoneInput.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if(isPass){
            return true
        } else {
            return false
        }
        
        
        
    }

}
