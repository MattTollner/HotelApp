//
//  EditRoomViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 17/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase


class EditRoomViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    
    //UI Elements
    @IBOutlet weak var roomPrice: UITextField!
    @IBOutlet weak var roomNumber: UITextField!
    @IBOutlet weak var roomType: UITextField!
    @IBOutlet weak var roomState: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var addRoomButton: UIButton!
    @IBOutlet weak var updateRoomButton: UIButton!
    @IBOutlet weak var addRoom: UIButton!
    @IBOutlet weak var labelOutput: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let thePickerView = UIPickerView()
    
    
    let db = Firestore.firestore()
    
    //Room data
    var roomToUpdate : Room?
    var topRoom : Int?
    var roomsNumberList : [String] = []
    
   
    
    
    // Hold Current array
    var currentArr : [String] = []
    
    //Current text field
    var activeTextField : UITextField!
    
    let stateArray = ["Clean", "Unclean"]
    let typeArray = ["Single", "Double", "Double Single", "Family"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        //Keyboard bar button setup
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([doneButton], animated: true)
        
        roomNumber.inputAccessoryView = toolBar
        roomPrice.inputAccessoryView = toolBar
        roomState.inputAccessoryView = toolBar
        roomType.inputAccessoryView = toolBar
       
        
        
        //Inital setup
        roomState.delegate = self
        roomType.delegate = self
        
        thePickerView.delegate = self
        thePickerView.dataSource = self
        
        roomState.inputView = thePickerView
        roomType.inputView = thePickerView
        
        //Check room exists
        if let room = roomToUpdate{
            roomPrice.text = room.Price as? String
            roomNumber.text = room.Number
            roomType.text = room.RoomType
            roomState.text = room.RoomState
            addRoomButton.setTitle("Update Room", for: .normal)
        } else {
            print("ROOM TO UPDATE EMPTY REWIND SEGUE")
            self.performSegue(withIdentifier: "unwindEditRoom", sender: self)
        }
    }
    
    @objc func doneClicked(){
        self.view.endEditing(true)
    }
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //Populate picker with correct data
        activeTextField = textField
        switch textField {
        case roomType:
            currentArr = typeArray
        case roomState:
            currentArr = stateArray
        default:
            print("Default")
        }
        
        thePickerView.reloadAllComponents()
        return true
    }
    
    //Check input validity
    func checkLabels( ) -> Bool{
        var isPass = true
        
        roomPrice.text  = roomPrice.text?.replacingOccurrences(of: " ", with: "")
        roomState.text  = roomState.text?.replacingOccurrences(of: " ", with: "")
        
        
        if(roomNumber.text == ""){
            roomNumber.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        } else {
            roomNumber.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(roomPrice.text?.isNumeric != true){
            roomPrice.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            roomPrice.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        
        if(roomState.text == ""){
            roomState.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            roomState.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(roomState.text?.isAlpha == false){
            roomState.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            roomState.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(roomState.text != "Clean")
        {
            if(roomState.text != "Unclean"){
                roomState.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                isPass = false
            }
        }
        if(roomType.text == "" || roomType.text?.isAlpha == false){
            roomType.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            roomType.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        
        let types = ["Single", "Doulbe Single", "Double", "Family"]
        
        for i in types {
            if roomType.text == i {           
                roomType.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
                break
            } else {
                print("DB TYPE :: " + roomType.text!)
                print("OS TYPE :: " + i)
                roomType.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                isPass = false
            }
        }
        
        if let roomNum = roomNumber.text{
            if(roomsNumberList.contains(roomNum)){
                if(roomNum == roomToUpdate?.Number)
                {
                  
                } else {
                    isPass = false
                    fireError(titleText: "Room Number Exist", lowerText: "That room number appears to be on the database already")
                }
                
            }
        } else {
            isPass = false
        }
        
        
        
        if(isPass){
            return true
        } else {
            return false
        }
        
        
        
    }
    
    
    @IBAction func addRoom(_ sender: Any) {
        
        if let room = roomToUpdate{
        if checkLabels() {
            activityIndicator.startAnimating()
            self.updateRoomButton.isEnabled = false
            let roomDict : [String : Any] = ["Number" : roomNumber.text!, "Price" : roomPrice.text!,
                                             "RoomState" : roomState.text!, "RoomType" : roomType.text!, "RoomID" : room.RoomID]
            
          
            //Add room to fire base
            db.collection("Rooms").document(room.RoomID).setData(roomDict) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    self.fireError(titleText: "Error updating room", lowerText: err.localizedDescription)
                    self.activityIndicator.stopAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                    self.updateRoomButton.isEnabled = true
                    print("Document succesfully updated PERFORM SEGUE")
                    self.confirmAlert()
                }
            }
         
            } else {
                print("Fields incorrect")
            }
        }
    }
    
    func confirmAlert(){
        let successAlert = UIAlertController(title: "Room Updated", message: "Updated room information is now live", preferredStyle: UIAlertControllerStyle.alert)
        
        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "unwindEditRoom", sender: self)
        }))
        
        self.present(successAlert, animated: true, completion: nil)
    }
    
    func deleteRoom(){
        //Delete alert setup
        let delAlert = UIAlertController(title: "Delete Staff", message: "Are you sure you want to delete the staff account?", preferredStyle: UIAlertControllerStyle.alert)
        delAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.activityIndicator.startAnimating()
            
            
            //Delete firebase room
            self.db.collection("Room").document((self.roomToUpdate?.RoomID)!).delete() { err in
                if let err = err {
                    print("Error removing staff document: \(err)")
                    self.activityIndicator.stopAnimating()
                    self.fireError(titleText: "Error deleting staff!", lowerText: err.localizedDescription)
                } else {
                    self.activityIndicator.stopAnimating()
                    self.confirmAlert()
                }
            }
        }))
        
        delAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        self.present(delAlert, animated: true, completion: nil)
        
    
    }
    @IBAction func deleteRoomTapped(_ sender: Any) {
        deleteRoom()
    }
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
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
