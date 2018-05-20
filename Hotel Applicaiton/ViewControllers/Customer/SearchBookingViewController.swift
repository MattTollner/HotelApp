//
//  SearchBookingViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 18/03/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase
import PromiseKit

class SearchBookingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkOutLabel: UILabel!
    @IBOutlet weak var bookingStatusLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var amountPayedLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var bookingDatesLabel: UILabel!
    @IBOutlet weak var bookingStatusMiniLabel: UILabel!
    @IBOutlet weak var checkInTimeLabel: UILabel!
    @IBOutlet weak var checkOutTimeLabel: UILabel!
    @IBOutlet weak var bookedRoomsLabel: UILabel!
    @IBOutlet weak var amountPayedMiniLabel: UILabel!
    @IBOutlet weak var totalAmountMiniLabel: UILabel!
    @IBOutlet weak var cancelBookingButton: UIButton!
    
    
    
    var bookedRooms : [Room] = []
    var booking : Booking?
    var customer : Customer?
    
    let db = Firestore.firestore()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Inital Setup
        tableView.delegate = self
        tableView.dataSource = self
        errorLabel.isHidden = true
        hideElements()
        
        //Keyboard done button setup
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([doneButton], animated: true)
        searchBar.inputAccessoryView = toolBar
    }
    
    @objc func doneClicked(){
        //Close keyboard
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        if(searchBar.text == "") {
            searchBar.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            searchBar.placeholder?.append("Field cant be empty")
        } else {
            //Search for booking
            searchBar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            activityIndicator.startAnimating()
            searchBooking()
        }
        
    }
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    func addToArchive(){
        //Set booking to cancelled
        self.booking?.setBookingState(state: 3)
        let dict = self.booking?.getDict()
        
        //Add booking to archive and delete from booking database
        self.db.collection("BookingArchive").document((self.booking?.BookingID)!).setData(dict!, completion: { (error) in
            if error != nil {
                print("Error adding to archive")
                self.fireError(titleText: "Error adding booking to archive", lowerText: (error?.localizedDescription)!)
            } else {
                print("Adding booking to archive")
                //Delete from booking database
                self.db.collection("Booking").document((self.booking?.BookingID)!).delete() { (error) in
                    if let error = error {
                        print("Error deleting booking from booking table : \(error)")
                        self.fireError(titleText: "Error deleting booking from table", lowerText: error.localizedDescription)
                    } else {
                        print("Booking Deleted From Booking Table")
                        self.bookingStatusLabel.text = self.booking?.BookingStatus
                    }
                }
            }
        })
    }
    
    @IBAction func cancelBookingTapped(_ sender: Any) {
        let delAlert = UIAlertController(title: "Revoke Booking", message: "Are you sure you want to revoke the booking?", preferredStyle: UIAlertControllerStyle.alert)
        delAlert.addAction(UIAlertAction(title: "REVOKE", style: .default, handler: { (action: UIAlertAction!) in
            print("Setting booking to canceled")
            self.addToArchive()
        }))
        
        delAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            self.tableView.reloadData()
        }))
        
        self.present(delAlert, animated: true, completion: nil)
    }
    
    @IBAction func testButton(_ sender: Any) {
        //Populate data
        self.nameLabel.text = self.customer?.getFullName()
        self.checkInLabel.text = "Check In: " + (self.booking?.getCheckIn())!
        self.checkOutLabel.text = "Check Out: " + (self.booking?.getCheckOut())!
        self.bookingStatusLabel.text = self.booking?.BookingStatus
        self.amountPayedLabel.text = self.booking?.getAmountPayed()
        self.totalAmountLabel.text = self.booking?.getTotalAmount()
        self.showElements()
        self.tableView.reloadData()
    }
    
        
        
        //Promise Chain firebase Functions
        //Booking, room then customer
        func searchBooking()
        {
            bookedRooms = []
            promiseGetBookings()
                
                .then { obj -> Void in
                    self.promiseGetRoom(roomIDs: (self.booking?.RoomID)!)
                }
                
                .then { obj -> Void in
                    self.promiseGetCustomer(customerID: (self.booking?.CustomerID)!)
                }
                .catch(){
                    err in
                    print("Caught error")
            }
        }
    
    func promiseGetRoom(roomIDs : [String]) -> Promise<Any>{
            return Promise { fulfil,reject in
                let dispatchGroup = DispatchGroup()
                for (_, id) in roomIDs.enumerated() {
                    dispatchGroup.enter()
                    //Get rooms of booking
                    self.db.collection("Rooms").document(id).getDocument(completion: { (snapshot, error) in
                        print("Searching for room " + id)
                        if let error = error {
                            print(error.localizedDescription)
                            reject(error)
                        } else {
                           // print(snapshot?.data() ?? "Default HIT")
                            let room = Room(dictionary: snapshot?.data()! as! [String : AnyObject])
                            self.bookedRooms.append(room)
                            print("Appending to rooms list " + room.Number + " bookedRoomCount :: " + String(self.bookedRooms.count))
                            if(self.bookedRooms.count == roomIDs.count){
                                print(" :: Showing Elements :: ")
                                self.showElements()
                                self.tableView.reloadData()
                            }
                            dispatchGroup.leave()
                        }
                    })
                }
                print("Fulfil promiseGetRoom")
                fulfil("Win")
                
            }
        }
    
        func promiseGetCustomer(customerID : String) -> Promise<Customer>{
            return Promise { fulfil,reject in
                print("Searching for customer with id " + customerID)
                self.db.collection("Customer").document(customerID).getDocument(completion: { (snapshot, error) in
                    if let error = error {
                        reject(error)
                    } else {
                        self.customer = Customer(dictionary: snapshot?.data()! as! [String : AnyObject])
                        print("Success found customer")
                        self.nameLabel.text = self.customer?.getFullName()
                        self.checkInLabel.text = "Check In: " + (self.booking?.getCheckIn())!
                        self.checkOutLabel.text = "Check Out: " + (self.booking?.getCheckOut())!
                        self.bookingStatusLabel.text = self.booking?.BookingStatus
                        self.amountPayedLabel.text = self.booking?.getAmountPayedDisplay()
                        self.totalAmountLabel.text = self.booking?.getTotalAmountDisplay()
                        if (self.booking?.hasPayedFull())! {
                            self.amountPayedLabel.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                            self.totalAmountLabel.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                        }else{
                            self.amountPayedLabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                            self.totalAmountLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                        }
                        self.showElements()
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        fulfil(self.customer!)
                    }
                })
                
            }
        }
    
    
        func promiseGetBookings() -> Promise<Booking>{
            return Promise { fulfil, reject in
                
                errorLabel.isHidden = true
                let docRef = db.collection("Booking").document(searchBar.text!)
                
                docRef.getDocument { (document, error) in
                    if let error = error {
                    
                        reject(error)
                    }
                    if let document = document {
                        if document.exists{
                            print("Booking Found on database")
                            self.booking = Booking(dictionary: document.data()! as [String : AnyObject])
                            if let booking = self.booking {
                                if(booking.BookingStatus == "Cancelled")
                                {
                                   print("Found Nil when unwrapping")
                                    reject("Error" as! Error)
                                } else {
                                    fulfil(booking)
                                }
                                
                            } else {print("Found Nil when unwrapping"); reject("Error" as! Error)}
                        } else {
                            print(self.searchBar.text! + " : booking does not exist in the database")
                            self.errorLabel.isHidden = false
                            self.activityIndicator.stopAnimating()
                            self.hideElements()
                            
                            let errorTemp = NSError(domain:"", code:401, userInfo:nil)
                            reject(errorTemp as Error)
                        }
                    }
                }
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookedRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "updateBookingRoomCell", for: indexPath) as! UpdateBookingRoomTableViewCell
       
        if let booking = self.booking {
            cell.roomNumberLabel.text = bookedRooms[indexPath.row].Number
            cell.roomTypeLabel.text = "Type: " + bookedRooms[indexPath.row].RoomType
            
            //Check breakfast
            if (booking.Breakfast.contains(bookedRooms[indexPath.row].RoomID)){
                cell.roomBreakfastLabel.text = "Breakfast Included"
            } else {
                cell.roomBreakfastLabel.text = "No Breakfast"
            }
        }
        return cell
    }
    
    func hideElements() {
        self.nameLabel.isHidden = true
        self.checkInLabel.isHidden = true
        self.checkOutLabel.isHidden = true
        self.bookingStatusLabel.isHidden = true
        self.amountPayedLabel.isHidden = true
        self.totalAmountLabel.isHidden = true
        self.tableView.isHidden = true
        self.bookingStatusMiniLabel.isHidden = true
        self.bookingDatesLabel.isHidden = true
        self.checkInTimeLabel.isHidden = true
        self.checkOutTimeLabel.isHidden = true
        self.totalAmountMiniLabel.isHidden = true
        self.amountPayedMiniLabel.isHidden = true
        self.bookedRoomsLabel.isHidden = true
        self.cancelBookingButton.isHidden = true
        
    }
    
    func showElements() {
        self.nameLabel.isHidden = false
        self.checkInLabel.isHidden = false
        self.checkOutLabel.isHidden = false
        self.bookingStatusLabel.isHidden = false
        self.amountPayedLabel.isHidden = false
        self.totalAmountLabel.isHidden = false
        self.tableView.isHidden = false
        self.bookingStatusMiniLabel.isHidden = false
        self.bookingDatesLabel.isHidden = false
        self.checkInTimeLabel.isHidden = false
        self.checkOutTimeLabel.isHidden = false
        self.totalAmountMiniLabel.isHidden = false
        self.amountPayedMiniLabel.isHidden = false
        self.bookedRoomsLabel.isHidden = false
        self.cancelBookingButton.isHidden = false
    }


}


