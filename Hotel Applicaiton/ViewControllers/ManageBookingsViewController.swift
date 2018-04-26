//
//  ManageBookingsViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 02/03/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase
import PromiseKit

class ManageBookingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets
    @IBOutlet weak var checkInSegment: UISegmentedControl!
    @IBOutlet weak var timeSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    //Data
    var refinedBookingList = [Booking]()
    var refinedCustomerList = [Customer]()
    var bookingList = [Booking]()
    var customerList = [Customer]()
    var selectedBooking : Booking?
    var selectedCustomer : Customer?
    let db = Firestore.firestore()
    var calendar : Date?
    var todayDateStr : String?
    
    @IBOutlet weak var activityIndicatoer: UIActivityIndicatorView!
    @IBAction func unwindToManageBookings(segue:UIStoryboardSegue) {
    }
    
    @IBAction func refreshBookings(_ sender: Any) {
        activityIndicatoer.startAnimating()
        testQ(roomType: "jh")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return refinedBookingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" //Your date format
        let cell = tableView.dequeueReusableCell(withIdentifier: "manageBookingCell", for: indexPath) as! ManageBookingTableViewCell
        
        cell.nameLabel.text = refinedCustomerList[indexPath.row].getFullName()
        cell.checkInLabel.text = dateFormatter.string(from: refinedBookingList[indexPath.row].CheckIn)
        cell.checkOutLabel.text = dateFormatter.string(from: refinedBookingList[indexPath.row].CheckOut)
        cell.statusLabel.text = refinedBookingList[indexPath.row].BookingStatus
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        // updateRoom = true
        selectedBooking = refinedBookingList[selectedIndex]
        selectedCustomer = refinedCustomerList[selectedIndex]
        //selectedStaff.append(staffList[selectedIndex])
        performSegue(withIdentifier: "updateBooking", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  let destination = segue.destination as? UpdateBookingViewController {
            destination.selectedBooking = selectedBooking
            destination.selectedCustomer = selectedCustomer
            destination.selectedIndex = self.checkInSegment.selectedSegmentIndex
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "dd/MM/yyyy"
        todayDateStr = dateFormatter.string(from: currentDate)
        print("Todays date is " + todayDateStr!)
        testQ(roomType: "jh")
        activityIndicatoer.startAnimating()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTable(){
        refinedCustomerList = []
        refinedBookingList  = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" //Your date format
        let theDate = dateFormatter.date(from: todayDateStr!)
        
        var a : Int = Int(bookingList.endIndex)
        a -= 1
        
        print("Booking 1 date : " + dateFormatter.string(from: bookingList[0].CheckIn))
        
        if checkInSegment.selectedSegmentIndex == 0 {
            //Check In
            if timeSegment.selectedSegmentIndex == 0 {
                //All
                print("All")
                for i in 0...a {
                    refinedBookingList.append(bookingList[i])
                    refinedCustomerList.append(customerList[i])
                }
            } else if timeSegment.selectedSegmentIndex == 1 {
                //Past
                print("Past")
                for i in 0...a {
                    if bookingList[i].CheckIn.compare(theDate!) == .orderedAscending {
                        refinedBookingList.append(bookingList[i])
                        refinedCustomerList.append(customerList[i])
                    }
                }
            } else if timeSegment.selectedSegmentIndex == 2 {
                //Present
                print("Present")
                for i in 0...a{
                    if bookingList[i].CheckIn.compare(theDate!) == .orderedSame {
                        refinedBookingList.append(bookingList[i])
                        refinedCustomerList.append(customerList[i])
                    }
                }
            } else if timeSegment.selectedSegmentIndex == 3 {
                //Future
                print("Future")
                for i in 0...a {
                    if bookingList[i].CheckIn.compare(theDate!) == .orderedDescending {
                        refinedBookingList.append(bookingList[i])
                        refinedCustomerList.append(customerList[i])
                    }
                }
            } else  {
                print("Nothing")
            }
        } else {
            //Check Out
            if timeSegment.selectedSegmentIndex == 0 {
                //All
                print("All")
                for i in 0...a {
                    refinedBookingList.append(bookingList[i])
                    refinedCustomerList.append(customerList[i])
                }
            } else if timeSegment.selectedSegmentIndex == 1 {
                //Past
                print("Past")
                for i in 0...a {
                    if bookingList[i].CheckOut.compare(theDate!) == .orderedAscending {
                        refinedBookingList.append(bookingList[i])
                        refinedCustomerList.append(customerList[i])
                    }
                }
            } else if timeSegment.selectedSegmentIndex == 2 {
                //Present
                print("Present")
                for i in 0...a{
                    if bookingList[i].CheckOut.compare(theDate!) == .orderedSame {
                        refinedBookingList.append(bookingList[i])
                        refinedCustomerList.append(customerList[i])
                    }
                }
            } else if timeSegment.selectedSegmentIndex == 3 {
                //Future
                print("Future")
                for i in 0...a {
                    if bookingList[i].CheckOut.compare(theDate!) == .orderedDescending {
                        refinedBookingList.append(bookingList[i])
                        refinedCustomerList.append(customerList[i])
                    }
                }
            } else  {
                print("Nothing")
            }
        }
        
    }
    
    
    @IBAction func checkInChanged(_ sender: Any) {
        updateTable()
        tableView.reloadData()
    }

    @IBAction func timeChanged(_ sender: Any) {
        updateTable()
        tableView.reloadData()
    }
     var dispatchGroup = DispatchGroup()
    
    //Firebase Functions
    func testQ(roomType : String)
    {
        promiseGetBookings()
            
            .then { obj -> Void in
                var canBookRoomType = false
                for i in self.bookingList {
                    self.dispatchGroup.enter()
                    
                    self.db.collection("Customer").document(i.CustomerID ).getDocument(completion: { (snapshot, error) in
                        print("Searching for " + i.CustomerID)
                        if let error = error {
                            print(error.localizedDescription)
                            //self.dispatchGroup.leave()
                        } else {
                            let customer = Customer(dictionary: snapshot?.data() as! [String : AnyObject])
                            print("Appending to customer list " + customer.Forename)
                            self.customerList.append(customer)
                            self.dispatchGroup.leave()
                        }
                    })
                }
                
            }
            .then { obj -> Void in
                //self.tableView.reloadData()
                self.updateTable()
                self.tableView.reloadData()
                self.activityIndicatoer.stopAnimating()
                print("ENd")
            }
            .catch(){
                err in
                self.activityIndicatoer.stopAnimating()
                print("Caught error")
        }
    }
    
    func promiseGetCustomers(customerID : String) -> Promise<Customer>{
        return Promise { fulfil,reject in
            print("Searching for customer with id " + customerID)
            self.db.collection("Customer").document(customerID).getDocument(completion: { (snapshot, error) in
                if let error = error {
                    reject(error)
                } else {
                    let customer = Customer(dictionary: snapshot?.data() as! [String : AnyObject])
                    self.customerList.append(customer)
                    fulfil(customer)
                }
            })
            
        }
    }
    
    func promiseGetBookings() -> Promise<[Booking]>{
        return Promise { fulfil, reject in
            
            db.collection("Booking").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting staff documents : \(error)")
                    reject(error)
                } else
                {
                    print("Getting bookingss")
                    for document in snapshot!.documents {
                        // print("\(document.documentID) => \(document.data())")
                        
                        let booking = Booking(dictionary: document.data() as [String : AnyObject])
                        print("Booking " + booking.RoomID[0])
                        self.bookingList.append(booking)
                        //  self.tableView.reloadData()
                    }
                    
                    fulfil(self.bookingList)
                }
            }
            
        }
    }
    
    

}
