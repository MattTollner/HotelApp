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
    
 
    var roomToUpdate = [Room]()
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
        
        // Do any additional setup after loading the view.
        roomState.delegate = self
        roomType.delegate = self
        
        thePickerView.delegate = self
        thePickerView.dataSource = self
        
        roomState.inputView = thePickerView
        roomType.inputView = thePickerView
        
        
        if(!roomToUpdate.isEmpty)
        {
            roomPrice.text = roomToUpdate[0].Price as? String
            roomNumber.text = roomToUpdate[0].Number
            roomType.text = roomToUpdate[0].RoomType
            roomState.text = roomToUpdate[0].RoomState
            addRoomButton.setTitle("Update Room", for: .normal)
        }
  
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
        if(roomPrice.text?.isAlpha == false){
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
    
    @IBAction func addRoom(_ sender: Any) {
        
        
        if checkLabels() {
            var roomDict : [String : Any] = ["Number" : roomNumber.text!, "Price" : roomPrice.text!,
                                             "RoomState" : roomState.text!, "RoomType" : roomType.text!, "RoomID" : "Nil"]
            
            
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
                        "RoomState" : roomState.text!, "RoomType" : roomType.text!, "RoomID" : ref!.documentID]
            
            db.collection("Rooms").document(ref!.documentID).setData(roomDict) { (error) in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document updated stored id: \(ref!.documentID)")
                    self.performSegue(withIdentifier: "unwindEditRoom", sender: self)
                }
            }
        } else {
            print("Fields incorrect")
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
