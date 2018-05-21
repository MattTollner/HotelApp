//
//  ManageStaffTableViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 18/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase

class ManageStaffTableViewController: UITableViewController, UISearchBarDelegate {

    var staffList = [Staff]()
    var selectedStaff = [Staff]()
    let db = Firestore.firestore()    
 
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var tblView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let tempView = UIView()
    let spinner = UIActivityIndicatorView()
    let loadLabel = UILabel()
    
    @IBOutlet weak var segmentPicker: UISegmentedControl!
   
    
   var isSearching = false
    @IBAction func unwindToManageStaff(segue:UIStoryboardSegue) {
        print("Update Tables")
        segmentPicker.selectedSegmentIndex = 0
        segmentPicker.isEnabled = false
        getStaff()
    }
    
    @IBAction func refreshStaff(_ sender: Any) {
        segmentPicker.selectedSegmentIndex = 0
        segmentPicker.isEnabled = false
        getStaff()
    }
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentPicker.selectedSegmentIndex = 0
        activityIndicator.startAnimating()
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        self.searchBar.isHidden = true
        segmentPicker.isEnabled = false
        
        //Tool bar setup
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: true)
        searchBar.inputAccessoryView = toolBar
        
        getStaff()
        
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
            updateSeg()
            
        } else {
            print("Searching FALSE <<<>>><<>>>")
            isSearching = false
            updateSeg()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   //Segment chage
    func updateSeg(){
        selectedStaff.removeAll()
        
        if(isSearching){
            segmentPicker.isEnabled = false
            for i in staffList {
                if(i.Email == searchBar.text){
                    selectedStaff.append(i)
                }
            }
        }
        else
        {
            segmentPicker.isEnabled = true
            let segValue = segmentPicker.titleForSegment(at: segmentPicker.selectedSegmentIndex)
            print("Staff list count "  + String(staffList.count))
            if segmentPicker.selectedSegmentIndex == 3 {
                for staff in staffList
                {
                    selectedStaff.append(staff)
                }
            } else {
                for staff in staffList
                {
                    if(staff.StaffType == segValue){
                        selectedStaff.append(staff)
                    }
                }
            }
        }
        
        
        print(selectedStaff.count)
        
        tableView.reloadData()
    }
   
    @IBAction func segmentChange(_ sender: Any) {
       updateSeg()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedStaff.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "staffCell", for: indexPath) as! StaffTableViewCell
        
        if(selectedStaff.isEmpty)
        {
            print("SELECTED STAFF EMPTY ")
        } else {
            
            cell.nameLabel.text = selectedStaff[indexPath.row].Forename //+ " " + selectedStaff[indexPath.row].Sirname
            cell.emailLabel.text = selectedStaff[indexPath.row].Email
            
            switch selectedStaff[indexPath.row].StaffType {
            case "Admin":
                cell.staffTypeLabel.text = "A"
            case "Receptionist":
                cell.staffTypeLabel.text = "R"
            case "Cleaner":
                cell.staffTypeLabel.text = "C"
            default:
                cell.staffTypeLabel.text = "N/A"
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
       // updateRoom = true
       selectedStaff.append(staffList[selectedIndex])
       performSegue(withIdentifier: "editStaff", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if  let destination = segue.destination as? EditStaffViewController {
            destination.staffToUpdate = selectedStaff
        }
    }


    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sID = staffList[indexPath.row].StaffID
            db.collection("Staff").document(sID).delete() { err in
                if let err = err {
                    print("Error removing staff document: \(err)")
                    self.fireError(titleText: "Error deleting staff!", lowerText: err.localizedDescription)
                } else {
                    let delAlert = UIAlertController(title: "Delete Staff", message: "Are you sure you want to delete the staff account?", preferredStyle: UIAlertControllerStyle.alert)
                    delAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        print("Staff document successfully removed!")
                        print("s staff type " + self.selectedStaff[indexPath.row].Email)
                        print("Staff type " + self.staffList[indexPath.row].Email )
                        self.activityIndicator.startAnimating()
                        self.searchBar.isHidden = true
                        self.segmentPicker.selectedSegmentIndex = 0
                        self.segmentPicker.isEnabled = false
                        self.getStaff()
                    }))
                    
                    delAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                        tableView.reloadData()
                    }))
                    
                    self.present(delAlert, animated: true, completion: nil)
                    
                    
                }
            }
        }
    }
    

    func getStaff(){
        
        staffList.removeAll()
        selectedStaff.removeAll()
        
        db.collection("Staff").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting staff documents : \(error)")
                self.fireError(titleText: "Unable to fetch staff", lowerText: error.localizedDescription)
            } else
            {
                print("Staff document count:  " + String(describing: snapshot?.documents.count))
                for document in snapshot!.documents {
                   // print("\(document.documentID) => \(document.data())")
                    
                    let staff = Staff(dictionary: document.data() as [String : AnyObject])
                    self.staffList.append(staff)
                    print("Staff :: " + staff.Email)
                    if(staff.StaffType == "Admin"){
                        self.selectedStaff.append(staff)
                    }
                    self.tableView.reloadData()
                }
                print("stopping activiyt indicaotr")
                self.activityIndicator.stopAnimating()
                self.searchBar.isHidden = false
            }
        }
        
        
        segmentPicker.isEnabled = true
        tableView.reloadData()
        
        
    }


}
