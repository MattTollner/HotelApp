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
    
    var topRoom : Int = 0
    
    @IBOutlet weak var addRoom: UIButton!
    let thePickerView = UIPickerView()
    
    // Hold Current array
    var currentArr : [String] = []
    //Current text field
    var activeTextField : UITextField!
    let typeArray = ["Single", "Double", "Single Double", "Family"]
    @IBOutlet weak var labelOutput: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomPrice.keyboardType = UIKeyboardType.numberPad
        
        print("DB Reached")
        
        // Do any additional setup after loading the view.
     
        roomType.delegate = self
        
        thePickerView.delegate = self
        thePickerView.dataSource = self
        
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(closePicker))
  
        
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        

        roomType.inputView = thePickerView
 
        roomType.inputAccessoryView = toolBar
    
        highRoomNumLabel.text = "Highest Room Number : " + String(topRoom)
     
      
        
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
            var roomDict : [String : Any] = ["Number" : roomNumber.text!, "Price" : roomPrice.text!,
                                             "RoomState" : "Clean", "RoomType" : roomType.text!, "RoomID" : "Nil"]
            
            
            
            let db = Firestore.firestore()
            var ref: DocumentReference? = nil
            ref = db.collection("Rooms").addDocument(data: roomDict) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
            roomDict = ["Number" : roomNumber.text!, "Price" : roomPrice.text!,
                        "RoomState" : "Clean", "RoomType" : roomType.text!, "RoomID" : ref!.documentID]
            
            db.collection("Rooms").document(ref!.documentID).setData(roomDict) { (error) in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document updated stored id: \(ref!.documentID)")
                    self.performSegue(withIdentifier: "unwindAddRoom", sender: nil)            }
            }
        } else {
            print("Invalid input data")
        }
        
        
        
        
    }
    
    func checkLabels( ) -> Bool{
        var isPass = true
        
        if(roomNumber.text == ""){
            roomNumber.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        } else {
            roomNumber.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(roomPrice.text?.isAlpha == false){
            roomPrice.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            roomPrice.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
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
    
  
    
    
    @objc func closePicker(){
        
        self.view.endEditing(true)
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


