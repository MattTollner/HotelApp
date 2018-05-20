//
//  UpdateBookingViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 02/03/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase

class UpdateBookingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var bookingDateLabel: UILabel!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkOutLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var amountPayedLabel: UILabel!
    @IBOutlet weak var bookingStatusLabel: UILabel!
    @IBOutlet weak var checkInButton: UIButton!
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex : Int?
    var selectedBooking : Booking?
    var selectedCustomer : Customer?
    var bookedRooms : [Room] = []
    var tempBookedRooms : [Room] = []
    var checkOut : Bool = false
    
    let db = Firestore.firestore()
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookedRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "updateBookingRoomCell", for: indexPath) as! UpdateBookingRoomTableViewCell
        cell.roomTypeLabel.text = "Type: " + bookedRooms[indexPath.row].RoomType
        cell.roomNumberLabel.text = "Number: " + bookedRooms[indexPath.row].Number
        cell.roomStatusLabel.text = "Status: " + bookedRooms[indexPath.row].RoomState
        
        if (selectedBooking?.Breakfast.contains(bookedRooms[indexPath.row].RoomID))!{
            print("Room has payed for breakfast")
            cell.roomBreakfastLabel.text = "Breakfast"
        } else {
            print("Room has not payed for breakfast")
            cell.roomBreakfastLabel.text = "No Breakfast"
        }
        
        return cell
    }
    
    
    func colourPrice(){
        
        if let booking = selectedBooking {
            if (booking.hasPayedFull()) {
                totalAmountLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                amountPayedLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            } else {
                totalAmountLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                amountPayedLabel.textColor = #colorLiteral(red: 1, green: 0.2305787934, blue: 0.135325428, alpha: 1)
            }
        } else {
            print("Selected booking nil")
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        nameLabel.text = selectedCustomer?.getFullName()
        emailLabel.text = selectedCustomer?.Email
        
        
        colourPrice()
        
        bookingDateLabel.text = selectedBooking?.BookingDate
        checkInLabel.text = selectedBooking?.getCheckIn()
        checkOutLabel.text = selectedBooking?.getCheckOut()
        bookingStatusLabel.text = selectedBooking?.BookingStatus
        totalAmountLabel.text = selectedBooking?.getTotalAmountDisplay()
        amountPayedLabel.text = selectedBooking?.getAmountPayedDisplay()
        
        getRooms()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func cancelTapped(_ sender: Any) {
        if let booking = selectedBooking{
            if (booking.BookingStatus != "Checked Out" || booking.BookingStatus != "Cancelled") {
                booking.setBookingState(state: 3)
                let dict = booking.getDict()
                //First upload copy to booking archive
                self.db.collection("BookingArchive").document(booking.BookingID).setData(dict, completion: { (error) in
                    if error != nil {
                        print("Error adding to archive")
                        self.fireError(titleText: "Error adding booking to archive", lowerText: (error?.localizedDescription)!)
                    } else {
                        print("Adding booking to archive")
                        //Delete from main booking table
                        self.db.collection("Booking").document(booking.BookingID).delete() { (error) in
                            if let error = error {
                                print("Error deleting booking from booking table : \(error)")
                                self.fireError(titleText: "Error adding booking to archive", lowerText: error.localizedDescription)
                            } else {
                                print("Booking Deleted From Booking Table")
                               // self.setRoomsUnclean()
                                self.bookingStatusLabel.text = self.selectedBooking?.BookingStatus
                                self.fireError(titleText: "Booking Cancelled", lowerText: "Booking added to archive")
                                self.performSegue(withIdentifier: "unwindUpdateBooking", sender: self)
                            }
                        }
                    }
                })
                
            } else {
                showAlert(warning: "Cancel", status: (selectedBooking?.BookingStatus)!)
            }
        }
    }
    
    func showAlert(warning : String, status : String){
        let theAlert = UIAlertController(title: "Invalid Request", message: "Unable to " + warning + " due to booking status already being " + status, preferredStyle: UIAlertControllerStyle.alert)
        
        theAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in}))
        
        self.present(theAlert, animated: true, completion: nil)
    }
    
    func setRoomsUnclean(){
        if selectedBooking != nil {
            for i in bookedRooms {
                i.changeRoomState(index: 1)
                let dict = i.getDict()
                db.collection("Rooms").document(i.RoomID).setData(dict, completion: { (error) in
                    if let error = error {
                        print("Error updating room")
                        self.fireError(titleText: "Unable to set room status to unclean", lowerText: error.localizedDescription)
                    } else {
                        print("Room Status Updated")
                        
                    }
                })
            }
        }
    }
    
    
    
    
    
    
    
    var dispatchGroup = DispatchGroup()
    
    func getRooms(){
        for i in (selectedBooking?.RoomID)! {
            self.dispatchGroup.enter()
            
            self.db.collection("Rooms").document(i).getDocument(completion: { (snapshot, error) in
                print("Searching for room " + i)
                if let error = error {
                    print(error.localizedDescription)
                    self.fireError(titleText: "Error fetching room!", lowerText: error.localizedDescription)
                    //self.dispatchGroup.leave()
                } else {
                    let room = Room(dictionary: snapshot?.data() as! [String : AnyObject])
                    print("Appending Rooom to list Room Numb : " + room.Number + " Room ID " + room.RoomID )
                    
                    self.bookedRooms.append(room)
                    self.tableView.reloadData()
                    self.dispatchGroup.leave()
                }
            })
        }
    }
    
    func updateBooking(){
        var dict = selectedBooking?.getDict()
        db.collection("Booking").document((selectedBooking?.BookingID)!).setData(dict!) { (error) in
            if let error = error {
                print("Error updating booking (ID not set): \(error)")
                self.fireError(titleText: "Error updating booking id", lowerText: error.localizedDescription)
            } else {
                self.bookingStatusLabel.text = self.selectedBooking?.BookingStatus
            }
        }
    }
    
    func payedAlert(state : Int){
        let moneyAlert = UIAlertController(title: "Payment Outstanding", message: "Has the customer payed the outstadning amount?", preferredStyle: UIAlertControllerStyle.alert)
        moneyAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            print("Customer now checked in")
            self.selectedBooking?.payFull()
            self.amountPayedLabel.text = self.selectedBooking?.getAmountPayedDisplay()
            self.colourPrice()
            self.selectedBooking?.setBookingState(state: state)
            self.updateBooking()
        }))
        
        moneyAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            print("Customer not payed")
            self.colourPrice()
        }))
        
    }
    
    @IBAction func checkInTap(_ sender: Any) {
        if let book = selectedBooking {
            if(book.BookingStatus == "Booked"){
                if(book.hasPayedFull()){
                    print("Update BOOKING STATUS")
                    selectedBooking?.setBookingState(state: 1)
                    updateBooking()
                } else {
                    payedAlert(state: 1)
                }
                
                
            } else {
                print("Incorrect BOOKING STATUS check in")
                showAlert(warning: "Check In", status: (selectedBooking?.BookingStatus)!)
            }
        }
    }
    
    @IBAction func checkOutTap(_ sender: Any) {
        if let book = selectedBooking {
            if(book.BookingStatus == "Checked In"){
                if(book.hasPayedFull()){
                    print("Update BOOKING STATUS")
                    selectedBooking?.setBookingState(state: 2)
                    updateBooking()
                    let dict = book.getDict()
                    //First upload copy to booking archive
                    self.db.collection("BookingArchive").document(book.BookingID).setData(dict, completion: { (error) in
                        if error != nil {
                            print("Error adding to archive")
                            self.fireError(titleText: "Error adding booking to archive", lowerText: (error?.localizedDescription)!)
                        } else {
                            print("Adding booking to archive")
                            //Delete from main booking table
                            self.db.collection("Booking").document(book.BookingID).delete() { (error) in
                                if let error = error {
                                    print("Error deleting booking from booking table : \(error)")
                                    self.fireError(titleText: "Error adding booking to archive", lowerText: error.localizedDescription)
                                } else {
                                    print("Booking Deleted From Booking Table")
                                    self.setRoomsUnclean()
                                    self.bookingStatusLabel.text = self.selectedBooking?.BookingStatus
                                    self.fireError(titleText: "Booking Completed", lowerText: "Booking added to archive")
                                    
                                }
                            }
                        }
                    })
                    
                } else {
                    payedAlert(state: 2)
                }
            } else {
                print("Incorrect BOOKING STATUS")
                showAlert(warning: "Check Out", status: (selectedBooking?.BookingStatus)!)
            }
        }
    }
    
    func refreshTable(_ sender: Any) {
        print("Room Count " + String(describing: bookedRooms.count))
        print("Booking status " + (selectedBooking?.BookingStatus)!)
        bookingDateLabel.text = selectedBooking?.BookingDate
        checkInLabel.text = selectedBooking?.getCheckIn()
        checkOutLabel.text = selectedBooking?.getCheckOut()
        bookingStatusLabel.text = selectedBooking?.BookingStatus
        totalAmountLabel.text = selectedBooking?.getTotalAmountDisplay()
        amountPayedLabel.text = selectedBooking?.getAmountPayedDisplay()
        tableView.reloadData()
    }
    
    
}

