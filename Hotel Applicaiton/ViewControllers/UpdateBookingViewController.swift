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
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(bookedRooms == nil){
            return 0
        } else {
            return bookedRooms.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" //Your date format
        let cell = tableView.dequeueReusableCell(withIdentifier: "updateBookingRoomCell", for: indexPath) as! UpdateBookingRoomTableViewCell
        
        cell.roomTypeLabel.text = bookedRooms[indexPath.row].RoomType
        cell.roomNumberLabel.text = bookedRooms[indexPath.row].Number
        cell.roomStatusLabel.text = bookedRooms[indexPath.row].RoomState
       
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
        
        if let booking = selectedBooking {
            if (booking.BookingStatus == "Checked Out" || booking.BookingStatus == "Cancelled"){
                showAlert(warning: "Cancel", status: booking.BookingStatus)
            } else {
                let delAlert = UIAlertController(title: "Revoke Booking", message: "Are you sure you want to revoke the booking?", preferredStyle: UIAlertControllerStyle.alert)
                delAlert.addAction(UIAlertAction(title: "REVOKE", style: .default, handler: { (action: UIAlertAction!) in
                    print("Setting booking to canceled")
                    self.checkInOut(bookingState: 3)
                    
                }))
                
                delAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    self.tableView.reloadData()
                }))
                
                self.present(delAlert, animated: true, completion: nil)
            }
        }        
    }
    
    func showAlert(warning : String, status : String){
        let theAlert = UIAlertController(title: "Invalid Request", message: "Unable to " + warning + " due to booking status already being " + status, preferredStyle: UIAlertControllerStyle.alert)
        
        theAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in}))
        
        self.present(theAlert, animated: true, completion: nil)
    }
    
    @IBAction func checkInTapped(_ sender: Any) {
        
        if let booking = selectedBooking {
            if(booking.BookingStatus == "Booked")
            {
                
                if(booking.hasPayedFull()){
                    //No payment needed
                    checkInOut(bookingState: 1)
                } else {
                    //Payment required to check in
                    let moneyAlert = UIAlertController(title: "Payment Outstanding", message: "Has the customer payed the outstadning amount?", preferredStyle: UIAlertControllerStyle.alert)
                    moneyAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                        print("Customer now checked in")
                        self.checkInOut(bookingState: 1)
                        
                    }))
                    
                    moneyAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in}))
                    
                    self.present(moneyAlert, animated: true, completion: nil)
                }
            } else {
                showAlert(warning: "Check In", status: booking.BookingStatus)
            }
        }
    }
    
    @IBAction func checkOutTapped(_ sender: Any) {
        
        
        
        if let booking = selectedBooking {
            if booking.BookingStatus == "Checked In" {
                
            
            if(booking.hasPayedFull()){
                //No payment needed
                checkInOut(bookingState: 2)
            } else {
                //Payment required to check in
                let moneyAlert = UIAlertController(title: "Payment Outstanding", message: "Has the customer payed the outstadning amount?", preferredStyle: UIAlertControllerStyle.alert)
                moneyAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    print("Customer now checked out")
                    self.checkInOut(bookingState: 2)
                    
                }))
                
                moneyAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in}))
                
                self.present(moneyAlert, animated: true, completion: nil)
            }
            } else {
                showAlert(warning: "Check Out", status: booking.BookingStatus)
            }
        }
    }
    
    
    
    func checkInOut(bookingState : Int){
        print("Selected Booking State " + (selectedBooking?.BookingStatus)!)
        print("Booking ID : " + (selectedBooking?.BookingID)!)
        
        selectedBooking?.setBookingState(state: bookingState)
        selectedBooking?.payFull()
        colourPrice()
        let dict = selectedBooking?.getDict()
        
        if let bID1 = selectedBooking?.BookingID {
            if (bookingState == 2 || bookingState == 3){
                self.db.collection("BookingArchive").document(bID1).setData(dict!, completion: { (error) in
                    if error != nil {
                        print("Error adding to archive")
                    } else {
                        print("Adding booking to archive")
                        self.db.collection("Booking").document(bID1).delete() { (error) in
                            if let error = error {
                                print("Error deleting booking from booking table : \(error)")
                            } else {
                                print("Booking Deleted From Booking Table")
                                if(bookingState == 2){
                                    print("Setting room unclean")
                                    self.setRoomsUnclean()
                                }
                                self.bookingStatusLabel.text = self.selectedBooking?.BookingStatus
                            }
                        }
                    }
                })
            }
        } else {
            if let bId = selectedBooking?.BookingID {
                db.collection("Booking").document(bId).setData(dict!) { (error) in
                    if let error = error {
                        print("Error updating booking (ID not set): \(error)")
                    } else {
                        if(bookingState == 1){
                            print("Booking state updated to Checked In : stored id: \(bId)")
                            self.amountPayedLabel.text = self.selectedBooking?.getAmountPayedDisplay()
                            self.bookingStatusLabel.text = self.selectedBooking?.BookingStatus
                        }
                        else if (bookingState == 0) {
                            print("Booking state updated to Booked : stored id: \(bId)")
                            self.bookingStatusLabel.text = self.selectedBooking?.BookingStatus
                        }
                        self.bookingStatusLabel.text = self.selectedBooking?.BookingStatus
                    }
                }
            } else {
                print("Selected Booking Empty")
            }
        }
        
        
    }
    
    func setRoomsUnclean(){
        if let booking = selectedBooking {
            for i in bookedRooms {
                i.changeRoomState(index: 1)
                let dict = i.getDict()
                db.collection("Rooms").document(i.RoomID).setData(dict, completion: { (error) in
                    if let error = error {
                        print("Error updating room")
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
    

    @IBAction func refreshTable(_ sender: Any) {
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
