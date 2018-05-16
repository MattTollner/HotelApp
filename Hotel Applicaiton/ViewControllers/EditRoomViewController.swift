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

    @IBOutlet weak var roomPrice: UITextField!
    @IBOutlet weak var roomNumber: UITextField!
    @IBOutlet weak var roomType: UITextField!
    @IBOutlet weak var roomState: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var addRoomButton: UIButton!
    
 
    var roomToUpdate : Room?
    var topRoom : Int?
 
    
    @IBOutlet weak var addRoom: UIButton!
    let thePickerView = UIPickerView()
    
    // Hold Current array
    var currentArr : [String] = []
    //Current text field
    var activeTextField : UITextField!
    let stateArray = ["Clean", "Unclean"]
    let typeArray = ["Single", "Double", "Double Single", "Family"]
    @IBOutlet weak var labelOutput: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("DB Reached")
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
       
        
        toolBar.setItems([doneButton], animated: true)
        
        roomNumber.inputAccessoryView = toolBar
        roomPrice.inputAccessoryView = toolBar
        roomState.inputAccessoryView = toolBar
        roomType.inputAccessoryView = toolBar
       
        
        
        // Do any additional setup after loading the view.
        roomState.delegate = self
        roomType.delegate = self
        
        thePickerView.delegate = self
        thePickerView.dataSource = self
        
        roomState.inputView = thePickerView
        roomType.inputView = thePickerView
        
        if let room = roomToUpdate{
            roomPrice.text = room.Price as? String
            roomNumber.text = room.Number
            roomType.text = room.RoomType
            roomState.text = room.RoomState
            addRoomButton.setTitle("Update Room", for: .normal)
        } else {
            print("ROOM TO UPDATE EMPTY REWIND SEGUE")
        }
        
     
  
    }
    
    @objc func doneClicked(){
        self.view.endEditing(true)
    }
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
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
    
    func checkLabels( ) -> Bool{
        var isPass = true
        
        if(roomNumber.text == ""){
            roomNumber.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        } else {
            roomNumber.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(roomPrice.text?.isAlpha == true){
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
                isPass = true
                roomType.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
                break
            } else {
                print("DB TYPE :: " + roomType.text!)
                print("OS TYPE :: " + i)
                roomType.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                isPass = false
            }
        }
        
        if(isPass){
            return true
        } else {
            return false
        }
        
        
        
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func addRoom(_ sender: Any) {
        
        if let room = roomToUpdate{
            
        
        
        if checkLabels() {
            activityIndicator.startAnimating()
            self.updateRoomButton.isEnabled = false
            let roomDict : [String : Any] = ["Number" : roomNumber.text!, "Price" : roomPrice.text!,
                                             "RoomState" : roomState.text!, "RoomType" : roomType.text!, "RoomID" : room.RoomID]
            
            let db = Firestore.firestore()
            db.collection("Rooms").document(room.RoomID).setData(roomDict) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    self.fireError(titleText: "Error updating room", lowerText: err.localizedDescription)
                    self.activityIndicator.stopAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                    self.updateRoomButton.isEnabled = true
                    print("Document succesfully updated PERFORM SEGUE")
                }
            }
         
            } else {
                print("Fields incorrect")
            }
        }
    }
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBOutlet weak var updateRoomButton: UIButton!
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
