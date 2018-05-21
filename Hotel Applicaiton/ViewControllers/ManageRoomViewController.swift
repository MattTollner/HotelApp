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

class ManageRoomViewController: UITableViewController, UISearchBarDelegate {
    
    var filteredRoomList = [Room]()
    var roomsList = [Room]()
    var roomNumberList : [String] = []
    var updateRoom = false;
    var selectedRoom : Room?
    var topRoom = 0
    let db = Firestore.firestore()
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var daf: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.selectedSegmentIndex = 0
        activityIndicator.startAnimating()
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        self.searchBar.isHidden = true
        segmentControl.isEnabled = false
        
        //Tool bar setup
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: true)
        searchBar.inputAccessoryView = toolBar
        getRooms()
    }
    
    @objc func doneClicked(){
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("SErach bar button CLIKDED <><><>")
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searach end edit " + searchBar.text!)
        if(searchBar.text != ""){
            print("Searching true")
            isSearching = true
            roomChangeFunc()
            
        } else {
            print("Searching FALSE <<<>>><<>>>")
            isSearching = false
            roomChangeFunc()
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue){
        print("Uwind")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRoomList.count
    }
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath) as! RoomTableViewCell
        cell.roomNumber.text = "Number: " + filteredRoomList[indexPath.row].Number
        cell.roomType.text =   "Type: " + filteredRoomList[indexPath.row].RoomType
        cell.roomPrice.text =  "Night: £" + filteredRoomList[indexPath.row].Price as? String
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Populate selected room data
        let selectedIndex = indexPath.row
        updateRoom = true
        selectedRoom = filteredRoomList[selectedIndex]
        performSegue(withIdentifier: "editRoom", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //Delete Room
        if editingStyle == .delete {
            let rID = filteredRoomList[indexPath.row].RoomID
            
            //Firebase ID delete
            db.collection("Rooms").document(rID).delete() { err in
                //Error
                if let err = err {
                    print("Error removing document: \(err)")
                    self.fireError(titleText: "Error deleting room!", lowerText: err.localizedDescription)
                }
                else
                {
                    let delAlert = UIAlertController(title: "Delete Room", message: "Are you sure you want to delete the room?", preferredStyle: UIAlertControllerStyle.alert)
                    delAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        print("Document successfully removed!")
                        
                        //Refresh data
                        self.activityIndicator.startAnimating()
                        self.getRooms()
                        self.segmentControl.selectedSegmentIndex = 0
                        self.segmentControl.isEnabled = false
                        self.searchBar.isHidden = false
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
        //Filter room table by type
        filteredRoomList = []
        
        if(isSearching){
            //Filer using seach
            print("Using search")
            for i in roomsList{
                if (i.Number == searchBar.text){
                    print("Added Room To Filtered")
                    filteredRoomList.append(i)
                }
            }
            print("Relaoding table")
            tableView.reloadData()
            segmentControl.isEnabled = false
            
        } else {
            segmentControl.isEnabled   = true
            //Filter with segment
            for i in roomsList {
                if segmentControl.selectedSegmentIndex == 0 {
                    if i.RoomType == "Single" {
                        filteredRoomList.append(i)
                    }
                } else if segmentControl.selectedSegmentIndex == 1 {
                    if i.RoomType == "Double Single" {
                        filteredRoomList.append(i)
                    }
                } else if segmentControl.selectedSegmentIndex == 2 {
                    if i.RoomType == "Double" {
                        filteredRoomList.append(i)
                    }
                } else if segmentControl.selectedSegmentIndex == 3 {
                    if i.RoomType == "Family" {
                        filteredRoomList.append(i)
                    }
                } else {
                    print("INCORRECT ROOM TYPE :: ERROR")
                }
                
            }
            
            tableView.reloadData()
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
        print("Refreshing Tables")
        activityIndicator.startAnimating()
        getRooms()
        segmentControl.selectedSegmentIndex = 0
    }
    
    //Populates edit room vars
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(updateRoom == true) {
            if  let destination = segue.destination as? EditRoomViewController {
                destination.roomToUpdate = selectedRoom
                destination.roomsNumberList = roomNumberList
            } 
        }
        
        if let destination = segue.destination as? CreateRoomViewController{
            destination.topRoom = topRoom
            destination.roomsNumberList = roomNumberList
        }
    }
    
    func getLastRoom(){
        //Gets hightest room number
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
        //Refresh table data
        activityIndicator.startAnimating()
        getRooms()
        segmentControl.selectedSegmentIndex = 0
        segmentControl.isEnabled = false
        searchBar.isHidden = true
    }
    
    func getRooms(){
        self.roomsList.removeAll()
        self.filteredRoomList.removeAll()
        db.collection("Rooms").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                self.fireError(titleText: "Error fetching rooms!", lowerText: error.localizedDescription)
                self.activityIndicator.stopAnimating()
            } else {
                for document in snapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let rooms = Room(dictionary: document.data() as [String : AnyObject])
                    self.roomsList.append(rooms)
                    self.roomNumberList.append(rooms.Number)
                    if(rooms.RoomType == "Single"){
                        self.filteredRoomList.append(rooms)
                    }
                    self.segmentControl.isEnabled = true
                    self.searchBar.isHidden = false
                    self.tableView.reloadData()
                }
            }
            
            if self.roomsList.count > 0 {
                self.getLastRoom()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
