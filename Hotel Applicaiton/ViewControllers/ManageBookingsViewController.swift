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

class ManageBookingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //Outlets
    @IBOutlet weak var checkInSegment: UISegmentedControl!
    @IBOutlet weak var timeSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
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
    
    //Serach bar
    var isSearching = false
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func unwindToManageBookings(segue:UIStoryboardSegue) {
        print("Home page moved")
        APIClient.customerOkay = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searach end edit " + searchBar.text!)
        if(searchBar.text != ""){
            print("Searching true")
            isSearching = true
            updateTable()
            
        } else {
            print("Searching FALSE <<<>>><<>>>")
            isSearching = false
            updateTable()
        }
    }
    
    //Format table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return refinedBookingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Table Set")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" //Your date format
        let cell = tableView.dequeueReusableCell(withIdentifier: "manageBookingCell", for: indexPath) as! ManageBookingTableViewCell
        
        cell.nameLabel.text =     "Name:  " + refinedCustomerList[indexPath.row].getFullName()
        cell.checkInLabel.text =  "Check In:  " + dateFormatter.string(from: refinedBookingList[indexPath.row].CheckIn)
        cell.checkOutLabel.text = "Check Out:  " + dateFormatter.string(from: refinedBookingList[indexPath.row].CheckOut)
        cell.statusLabel.text =   "Status:  " + refinedBookingList[indexPath.row].BookingStatus
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        selectedBooking = refinedBookingList[selectedIndex]
        selectedCustomer = refinedCustomerList[selectedIndex]
        performSegue(withIdentifier: "updateBooking", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let destination = segue.destination as? UpdateBookingViewController {
            destination.selectedBooking = selectedBooking
            destination.selectedCustomer = selectedCustomer
            destination.selectedIndex = self.checkInSegment.selectedSegmentIndex
        }
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        activityIndicator.startAnimating()
        timeSegment.selectedSegmentIndex = 0
        checkInSegment.selectedSegmentIndex = 0
        getBookingChain()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        //Tool bar setup
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        
        toolBar.setItems([doneButton], animated: true)
        
        searchBar.inputAccessoryView = toolBar
        
        //Populate todays date
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "dd/MM/yyyy"
        todayDateStr = dateFormatter.string(from: currentDate)
        print("Todays date is " + todayDateStr!)
        calendar = dateFormatter.date(from: todayDateStr!)
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        getBookingChain()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func doneClicked(){
        self.view.endEditing(true)
    }
 
   func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("SErach bar button CLIKDED <><><>")
        searchBar.resignFirstResponder()
    }
    
  
    func updateTable(){
        
        
        if bookingList.isEmpty{
            print("BOOKING LIST EMPTY :: ERROR CAUGHT")
        } else {
            
            print("Updateing Table FUnc")
            refinedCustomerList = []
            refinedBookingList  = []
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy" //Your date format
            let theDate = dateFormatter.date(from: todayDateStr!)
            var a : Int = Int(bookingList.endIndex)
            a -= 1
            
            //ERROR WAS ERE
            print("Booking 1 date : " + dateFormatter.string(from: bookingList[0].CheckIn))
            
            if(isSearching){
                //Filter by search
                checkInSegment.isEnabled = false
                timeSegment.isEnabled = false
                
                print("Customer List Count " + String(customerList.count))
                print("Booking List Count " + String(bookingList.count))
                for i in 0...(customerList.count - 1) {
                    if (customerList[i].Email == searchBar.text){
                        refinedBookingList.append(bookingList[i])
                        refinedCustomerList.append(customerList[i])
                        print("Refined booking count " + String(refinedBookingList.count))
                    }
                }
                tableView.reloadData()
            } else {
                checkInSegment.isEnabled = true
                timeSegment.isEnabled = true
                //USE segments
                if checkInSegment.selectedSegmentIndex == 0 {
                    //Check In
                    if timeSegment.selectedSegmentIndex == 0 {
                        //All
                        print("All")
                        for i in 0...a {
                            refinedBookingList.append(bookingList[i])
                            refinedCustomerList.append(customerList[i])
                        }
                        tableView.reloadData()
                    } else if timeSegment.selectedSegmentIndex == 1 {
                        //Past
                        print("Past")
                        for i in 0...a {
                            if bookingList[i].CheckIn.compare(theDate!) == .orderedAscending {
                                refinedBookingList.append(bookingList[i])
                                refinedCustomerList.append(customerList[i])
                            }
                        }
                        tableView.reloadData()
                    } else if timeSegment.selectedSegmentIndex == 2 {
                        //Present
                        print("Present")
                        for i in 0...a{
                            if bookingList[i].CheckIn.compare(theDate!) == .orderedSame {
                                refinedBookingList.append(bookingList[i])
                                refinedCustomerList.append(customerList[i])
                            }
                        }
                        tableView.reloadData()
                    } else if timeSegment.selectedSegmentIndex == 3 {
                        //Future
                        print("Future")
                        for i in 0...a {
                            if bookingList[i].CheckIn.compare(theDate!) == .orderedDescending {
                                refinedBookingList.append(bookingList[i])
                                refinedCustomerList.append(customerList[i])
                            }
                        }
                        tableView.reloadData()
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
                        tableView.reloadData()
                    } else if timeSegment.selectedSegmentIndex == 1 {
                        //Past
                        print("Past")
                        for i in 0...a {
                            if bookingList[i].CheckOut.compare(theDate!) == .orderedAscending {
                                refinedBookingList.append(bookingList[i])
                                refinedCustomerList.append(customerList[i])
                            }
                        }
                        tableView.reloadData()
                    } else if timeSegment.selectedSegmentIndex == 2 {
                        //Present
                        print("Present")
                        for i in 0...a{
                            if bookingList[i].CheckOut.compare(theDate!) == .orderedSame {
                                refinedBookingList.append(bookingList[i])
                                refinedCustomerList.append(customerList[i])
                            }
                        }
                        tableView.reloadData()
                    } else if timeSegment.selectedSegmentIndex == 3 {
                        //Future
                        print("Future")
                        for i in 0...a {
                            if bookingList[i].CheckOut.compare(theDate!) == .orderedDescending {
                                refinedBookingList.append(bookingList[i])
                                refinedCustomerList.append(customerList[i])
                            }
                        }
                        tableView.reloadData()
                    } else  {
                        print("Nothing")
                    }
                    
                    tableView.reloadData()
           
            }
        }
        }
        
    }
    
    //Called when segment changed
    @IBAction func checkInChanged(_ sender: Any) {
        if(bookingList.isEmpty){
            print("No bookings to filter")
        } else {
            updateTable()
        }
        tableView.reloadData()
    }
    
    @IBAction func timeChanged(_ sender: Any) {
        updateTable()
        tableView.reloadData()
    }
    var dispatchGroup = DispatchGroup()
    
    @IBAction func refreshData(_ sender: Any) {
        activityIndicator.startAnimating()
        refinedBookingList = []
        refinedCustomerList = []
        checkInSegment.selectedSegmentIndex = 0
        timeSegment.selectedSegmentIndex = 0
        getBookingChain()
    }
    
    //Firebase Functions
    func getBookingChain()
    {
        
        promiseGetBookings()
            
            .then { obj -> Void in
                var bListCount : Int
                var index : Int = 0
                bListCount = self.bookingList.count
                print("bListCount :: " + String(bListCount))
                
                //Loop trough booking list fetching customer details of each
                for i in self.bookingList {
                    
                    print("i Index :: " + String(describing: i))
                    self.dispatchGroup.enter()
                    
                    self.db.collection("Customer").document(i.CustomerID ).getDocument(completion: { (snapshot, error) in
                        print("Searching for " + i.CustomerID)
                        if let error = error {
                            print(error.localizedDescription)
                        } else
                        {
                            //Customer found appending to list
                            let customer = Customer(dictionary: snapshot?.data() as! [String : AnyObject])
                            self.customerList.append(customer)
                            index += 1
                            
                            print("Customer LIst COunt : " + String(self.customerList.count))
                            
                            //Check if at end of loop
                            if index == bListCount{
                                print("End of loop")
                                self.updateTable()
                                self.activityIndicator.stopAnimating()
                                self.tableView.reloadData()
                            }
                            self.dispatchGroup.leave()
                            
                        }
                    })
                }
                
                
            }
            .then { obj -> Void in
                print("ENd :: Custerom List : " + String(self.customerList.count) + " BookingList :: " + String(self.bookingList.count))
                self.activityIndicator.stopAnimating()
                if self.bookingList.count == 0{
                    print("no bookings")
                    self.timeSegment.isEnabled = false
                    self.checkInSegment.isEnabled = false
                } else {
                    self.timeSegment.isEnabled = true
                    self.checkInSegment.isEnabled = true
                }
            }
            .catch(){
                err in
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
                    print("Customer added :" + String( self.customerList.count))
                    fulfil(customer)
                }
            })
            
        }
    }
    
    func promiseGetBookings() -> Promise<[Booking]>{
        return Promise { fulfil, reject in
            
            //Get firebase bookings
            db.collection("Booking").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting staff documents : \(error)")
                    reject(error)
                } else
                {
                    self.customerList = []
                    self.bookingList = []
                    print("Getting bookingss")
                    for document in snapshot!.documents {
                        //Popoulate booking list
                        let booking = Booking(dictionary: document.data() as [String : AnyObject])
                        print("Booking " + booking.RoomID[0])
                        self.bookingList.append(booking)
                        
                    }
                    
                    fulfil(self.bookingList)
                }
            }
            
        }
    }
    
    
    
}
