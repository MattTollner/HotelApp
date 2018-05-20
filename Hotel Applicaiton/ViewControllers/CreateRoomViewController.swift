//
//  CreateRoomViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 12/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import FirebaseFirestore

class CreateRoomViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var roomPrice: UITextField!
    @IBOutlet weak var roomNumber: UITextField!
    @IBOutlet weak var roomType: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var addRoomButton: UIButton!
    @IBOutlet weak var highRoomNumLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var topRoom : Int = 0
    
    @IBOutlet weak var addRoom: UIButton!
    let thePickerView = UIPickerView()
    
    // Hold Current array
    var currentArr : [String] = []
    var roomsNumberList : [String] = []
    //Picker views
    var activeTextField : UITextField!
    let typeArray = ["Single", "Double", "Double Single", "Family"]
    @IBOutlet weak var labelOutput: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Inital setup
        roomPrice.keyboardType = UIKeyboardType.numberPad
        roomType.delegate = self
        thePickerView.delegate = self
        thePickerView.dataSource = self
        
        //Keyboard toolbar setup
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(closePicker))
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        //Input fields setup
        roomType.inputView = thePickerView
        roomType.inputAccessoryView = toolBar
        highRoomNumLabel.text = "Highest Room Number : " + String(topRoom)
     
        //Pickerview toolbar setup
        let toolBarText = UIToolbar()
        toolBarText.sizeToFit()
        let doneButton2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([doneButton], animated: true)
        toolBarText.setItems([doneButton2], animated: true)
        roomNumber.inputAccessoryView = toolBar
        roomPrice.inputAccessoryView = toolBar
        roomType.inputAccessoryView = toolBar
        
    }
    
    //Close keyboard
    @objc func doneClicked(){
        self.view.endEditing(true)
    }
    
    //Close picker
    @objc func closePicker(){
        
        self.view.endEditing(true)
    }
    
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        switch textField {
        case roomType:
            currentArr = typeArray
        default:
            print("Default")
        }
        
        thePickerView.reloadAllComponents()
        return true
    }
    
    @IBAction func addRoom(_ sender: Any) {
        
        if checkLabels() {
            activityIndicator.startAnimating()
            addRoom.isEnabled = false
            //Creat new room dict
            var roomDict : [String : Any] = ["Number" : roomNumber.text!, "Price" : roomPrice.text!,
                                             "RoomState" : "Clean", "RoomType" : roomType.text!, "RoomID" : "Nil"]
            
            
            
            let db = Firestore.firestore()
            var ref: DocumentReference? = nil
            ref = db.collection("Rooms").addDocument(data: roomDict) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    self.fireError(titleText: "Error adding room", lowerText: err.localizedDescription)
                    self.activityIndicator.stopAnimating()
                    self.addRoom.isEnabled = true
                    
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
            //Set room with new id
            
            roomDict = ["Number" : roomNumber.text!, "Price" : roomPrice.text!,
                        "RoomState" : "Clean", "RoomType" : roomType.text!, "RoomID" : ref!.documentID]
            
            //Update database data
            db.collection("Rooms").document(ref!.documentID).setData(roomDict) { (error) in
                if let error = error {
                    print("Error adding document: \(error)")
                    self.fireError(titleText: "Error adding room", lowerText: error.localizedDescription)

                    self.activityIndicator.stopAnimating()
                    self.addRoom.isEnabled = true
                } else {
                    print("Document updated stored id: \(ref!.documentID)")
                    self.activityIndicator.stopAnimating()
                    self.addRoom.isEnabled = true
                    self.performSegue(withIdentifier: "unwindAddRoom", sender: nil)
                    
                }
            }
        } else {
            print("Invalid input data")
            self.activityIndicator.stopAnimating()
            self.addRoom.isEnabled = true
        }
        
        
        
        
    }
    
    func checkLabels( ) -> Bool{
        var isPass = true
        
        roomPrice.text  = roomPrice.text?.replacingOccurrences(of: " ", with: "")
    
        
        if(roomNumber.text == ""){
            roomNumber.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        } else {
            roomNumber.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(roomPrice.text?.isNumeric != true){
            print("ROOM PRICE NOT GOOD")
            roomPrice.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            print("ROOM PRICE GOOD")
            roomPrice.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
      
        
        let types = ["Single", "Doulbe Single", "Double", "Family"]
        
        for i in types {
            if roomType.text == i {
                roomType.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
                break
            } else {
                roomType.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                isPass = false
            }
        }
        
        if(roomsNumberList.contains(roomNumber.text!)){
            isPass = false
            fireError(titleText: "Room Number Exist", lowerText: "That room number appears to be on the database already")
        }
        
        if(isPass){
            return true
        } else {
            return false
        }
    }
    
    //-- Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected Items", currentArr[row])
        activeTextField.text = currentArr[row]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


