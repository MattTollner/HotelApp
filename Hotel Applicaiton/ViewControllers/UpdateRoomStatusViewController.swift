//
//  UpdateRoomStatusViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 27/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase

class UpdateRoomStatusViewController: UIViewController {
    @IBOutlet weak var roomNumberLabel: UILabel!
    @IBOutlet weak var roomTypeLabel: UILabel!
    @IBOutlet weak var roomStatus: UILabel!
    @IBOutlet weak var roomStateSegmented: UISegmentedControl!
    let db = Firestore.firestore()
    var roomToUpdate : Room?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if roomToUpdate != nil {
            roomNumberLabel.text = roomToUpdate?.Number
            roomTypeLabel.text = roomToUpdate?.RoomType
            roomStatus.text = roomToUpdate?.RoomState
            
            if(roomToUpdate?.RoomState == "Clean"){
                roomStateSegmented.selectedSegmentIndex = 0
            } else {
                roomStateSegmented.selectedSegmentIndex = 1
            }
            
        } else {
            print("Room to update empty")
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func segmentChange(_ sender: Any) {
        if roomStateSegmented.selectedSegmentIndex == 0 {
            roomStatus.text = "Clean"
            roomToUpdate?.changeRoomState(index: 0)
        } else {
            roomStatus.text = "Unclean"
            roomToUpdate?.changeRoomState(index: 0)
        }
    }
    
    @IBAction func updateStatus(_ sender: Any) {
        
        let updatedRoom : [String : Any] = ["Number" : roomToUpdate?.Number as Any,
                                            "Price" : roomToUpdate?.Price as Any,
                                            "RoomID" : roomToUpdate?.RoomID as Any,
                                            "RoomState" : roomToUpdate?.RoomState as Any ,
                                            "RoomType" : roomToUpdate?.RoomType as Any]
        
        
        db.collection("Rooms").document((roomToUpdate?.RoomID)!).setData(updatedRoom) { err in
            if let err = err {
                print("Error updating room document: \(err)")
                self.fireError(titleText: "Error updating room status", lowerText: err.localizedDescription)
            } else {
                print("Room Updated")
                let successAlert = UIAlertController(title: "Success", message: "Room has been successfully updated", preferredStyle: UIAlertControllerStyle.alert)
                
                successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    print("Okay Pressed")
                }))
            }
        }
    }
    
    
}
