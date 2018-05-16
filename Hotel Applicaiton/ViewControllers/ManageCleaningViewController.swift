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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCellCleaning", for: indexPath) as! RoomCleaningTableViewCell
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        cell.roomTypeLabel.text = roomsList[indexPath.row].RoomType
        cell.roomNumberLabel.text = roomsList[indexPath.row].Number
        cell.roomStatusLabel.text = roomsList[indexPath.row].RoomState
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        selectedRoom = (roomsList[selectedIndex])
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
                    print("\(document.documentID) => \(document.data())")
                    
                    let rooms = Room(dictionary: document.data() as [String : AnyObject])
                    print(rooms.RoomType)
                    print(rooms.Price)
                    self.roomsList.append(rooms)
                    self.tableView.reloadData()
                    
                }
            }
            
            print(self.roomsList.count)
        }
    }
    

}
