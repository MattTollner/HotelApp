//
//  ManageRoomViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 17/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class ManageRoomViewController: UITableViewController {

    var specifiedRoomList = [Room]()
    var roomsList = [Room]()
    var updateRoom = false;
    var selectedRoom = [Room]()
    var topRoom = 0
    let db = Firestore.firestore()
  
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        getRooms()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var daf: UIBarButtonItem!
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue){
        print("Room Created")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return specifiedRoomList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath) as! RoomTableViewCell
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        cell.roomNumber.text = specifiedRoomList[indexPath.row].RoomType
        cell.roomType.text = specifiedRoomList[indexPath.row].RoomType
        cell.roomPrice.text = specifiedRoomList[indexPath.row].Price as? String
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        updateRoom = true
        selectedRoom.append(specifiedRoomList[selectedIndex])
        performSegue(withIdentifier: "editRoom", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let rID = specifiedRoomList[indexPath.row].RoomID
            db.collection("Rooms").document(rID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    let delAlert = UIAlertController(title: "Delete Room", message: "Are you sure you want to delete the room?", preferredStyle: UIAlertControllerStyle.alert)
                    delAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        print("Document successfully removed!")
                        
                        for i in 1...self.roomsList.count{
                            print("roomsList count : " + String(self.roomsList.count))
                            if self.specifiedRoomList[indexPath.row].RoomID == self.roomsList[i].RoomID
                            {
                                print("Found Same ID at index :: " + String(i))
                                self.roomsList.remove(at: i)
                                break
                            }
                        }
                        
                        self.specifiedRoomList.remove(at: indexPath.row)
                        
                        tableView.reloadData()
                    }))
                    
                    delAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                        tableView.reloadData()
                    }))
                    
                    self.present(delAlert, animated: true, completion: nil)

                    
                }
            }
        }
    }
    
    func roomChangeFunc(){
        specifiedRoomList = []
        for i in roomsList {
            if segmentControl.selectedSegmentIndex == 0 {
                if i.RoomType == "Single" {
                    specifiedRoomList.append(i)
                }
            } else if segmentControl.selectedSegmentIndex == 1 {
                if i.RoomType == "Double Single" {
                    specifiedRoomList.append(i)
                }
            } else if segmentControl.selectedSegmentIndex == 2 {
                if i.RoomType == "Double" {
                    specifiedRoomList.append(i)
                }
            } else if segmentControl.selectedSegmentIndex == 3 {
                if i.RoomType == "Family" {
                    specifiedRoomList.append(i)
                }
            } else {
                print("INCORRECT ROOM TYPE :: ERROR")
            }
            
        }
    }
    
    @IBAction func roomChange(_ sender: Any) {
        roomChangeFunc()
        tableView.reloadData()
    }
    @IBAction func newRoomTapped(_ sender: Any) {
        performSegue(withIdentifier: "addRoom", sender: self)
    }
    @IBAction func unwindToManageRoom(segue:UIStoryboardSegue) {
       print("Update Tables")
        activityIndicator.startAnimating()
        getRooms()
        segmentControl.selectedSegmentIndex = 0
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(updateRoom == true) {
            if  let destination = segue.destination as? EditRoomViewController {
                destination.roomToUpdate = selectedRoom
            }
        }
        
        if let destination = segue.destination as? CreateRoomViewController{
            destination.topRoom = topRoom
        }
    }
  
    func getLastRoom(){
        activityIndicator.stopAnimating()
        var end : Int = roomsList.endIndex
        end -= 1
        
        
        for i in 0...end{
            if let theNum = Int(roomsList[i].Number as String) {
                if(theNum > topRoom){
                    topRoom = theNum
                }
            } else {
                topRoom = 0
                break
            }
        }
        print("Top room number is " + String(topRoom))
        tableView.reloadData()
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        getRooms()
        segmentControl.selectedSegmentIndex = 0
    }
    
    func getRooms(){
        self.roomsList.removeAll()
        self.specifiedRoomList.removeAll()
        db.collection("Rooms").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                self.activityIndicator.stopAnimating()
            } else {
                for document in snapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let rooms = Room(dictionary: document.data() as [String : AnyObject])
                    self.roomsList.append(rooms)
                    if(rooms.RoomType == "Single"){
                       self.specifiedRoomList.append(rooms)
                    }
                    
                    self.tableView.reloadData()                    
                    
                }
            }
            
            print(self.roomsList.count)
            self.getLastRoom()
            
        }
    }
}
