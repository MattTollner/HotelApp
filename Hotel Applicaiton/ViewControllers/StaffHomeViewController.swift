//
//  StaffHomeViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 27/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase

class StaffHomeViewController: UIViewController {
    
    let alert = UIAlertController(title: "Permission Denied", message: "Account permissions unable to view content", preferredStyle: UIAlertControllerStyle.alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Checks if user logged in
        if (HelperClass.userTypeRefernce.userID == "NIL" || HelperClass.userTypeRefernce.userType == "NIL"){
            print("USER NOT LOGGED IN PERFROM SEGUE")
        }
        
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func unwindToStaffHome(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        print("Sign out")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        HelperClass.userTypeRefernce.userID = "NIL"
        HelperClass.userTypeRefernce.userType = "NIL"
        self.performSegue(withIdentifier: "unwindStaffHome", sender: self)
        
    }
    
    @IBAction func editInfoTapped(_ sender: Any) {
        if HelperClass.userTypeRefernce.userType == "Admin" {
            print("Perfrom Segue")
            performSegue(withIdentifier: "toEditInfo", sender: self)
        } else {
            print("Permission Denied")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func manageRoomsTapped(_ sender: Any) {
        if HelperClass.userTypeRefernce.userType == "Admin" {
            print("Perfrom Segue")
            performSegue(withIdentifier: "toManageRooms", sender: self)
        } else {
            print("Permission Denied")
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func manageStaffTapped(_ sender: Any) {
        if HelperClass.userTypeRefernce.userType == "Admin" {
            print("Perfrom Segue")
            performSegue(withIdentifier: "toManageStaff", sender: self)
        } else {
            print("Permission Denied")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func manageBookingsTapped(_ sender: Any) {
        if HelperClass.userTypeRefernce.userType == "Admin" || HelperClass.userTypeRefernce.userType == "Receptionist" {
            print("Perfrom Segue")
            performSegue(withIdentifier: "toManageBookings", sender: self)
        } else {
            print("Permission Denied")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func manageRoomCleaningTapped(_ sender: Any) {
        if HelperClass.userTypeRefernce.userType == "Admin" || HelperClass.userTypeRefernce.userType == "Cleaner" {
            print("Perfrom Segue")
            performSegue(withIdentifier: "toManageRoomCleaning", sender: self)
        } else {
            print("Permission Denied")
            self.present(alert, animated: true, completion: nil)
        }
    }
}
