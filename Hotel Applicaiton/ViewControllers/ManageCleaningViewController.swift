//
//  ManageCleaningViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 27/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase

class ManageCleaningViewController: UITableViewController {
    
    var roomsList = [Room]()
    var selectedRoomList = [Room]()
    var updateRoom = false;
    var selectedRoom : Room?
    let db = Firestore.firestore()

    
    @IBAction func unwindToManageCleaning(segue:UIStoryboardSegue) {
        
        
    }
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRooms()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBAction func segmentChange(_ sender: Any) {
        print("segment chagne")
        selectedRoomList.removeAll()
        if roomsList != nil{
            print("Reached here")
            if(segmentControl.selectedSegmentIndex == 0) {
                print("Segment Dirty")
                for i in roomsList {
                    if i.RoomState != "Clean" {
                        selectedRoomList.append(i)
                        print(i.Number + " roomState to sel room " + i.RoomState)
                    }
                }
            } else if(segmentControl.selectedSegmentIndex == 1) {
                print("Segment Clean")
                for i in roomsList {
                    if i.RoomState == "Clean" {
                        selectedRoomList.append(i)
                        print(i.Number + " roomState to sel room " + i.RoomState)
                    }
                }
            }
            
            tableView.reloadData()
        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedRoomList.count != 0 {
            print("Selected room list count : " + String(selectedRoomList.count))
            
            return selectedRoomList.count
        } else {
            print("Sel room empty setting number of rows to 0 ")
            return 0
        }

       
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCellCleaning", for: indexPath) as! RoomCleaningTableViewCell
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
    
        cell.roomTypeLabel.text = selectedRoomList[indexPath.row].RoomType
        cell.roomNumberLabel.text = selectedRoomList[indexPath.row].Number
        cell.roomStatusLabel.text = selectedRoomList[indexPath.row].RoomState
            
      
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        selectedRoom = (selectedRoomList[selectedIndex])
        performSegue(withIdentifier: "editRoomCleaning", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  
            if  let destination = segue.destination as? UpdateRoomStatusViewController {
                destination.roomToUpdate = selectedRoom
            }
        
    }
    
    
    func getRooms(){
        db.collection("Rooms").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                self.fireError(titleText: "Error fetching rooms", lowerText: error.localizedDescription)
            } else {
                for document in snapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    
                    let rooms = Room(dictionary: document.data() as [String : AnyObject])
                    print(rooms.RoomType + " " + rooms.Price + " " + rooms.RoomState )
          
                    self.roomsList.append(rooms)
                   
                    if(rooms.RoomState != "Clean"){
                        print("Detected unclean room adding to selectedRoomList")
                        self.selectedRoomList.append(rooms)
                        print("Count " + String(self.selectedRoomList.count))
                    }
                    
                    
                }
            }
            
            print("ROOM LIST COUNT :: " + String(self.roomsList.count))
            self.tableView.reloadData()
        }
    }
    

}
