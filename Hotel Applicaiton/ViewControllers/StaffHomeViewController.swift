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
         navigationItem.hidesBackButton = true;
        //Checks if user logged in
        if (HelperClass.userTypeRefernce.userID == "NIL" || HelperClass.userTypeRefernce.userType == "NIL"){
            print("USER NOT LOGGED IN PERFROM SEGUE")
            performSegue(withIdentifier: "unwindStaffHome", sender: nil)
        }
        
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func unwindToStaffHome(segue:UIStoryboardSegue) {
        
    }
    
    
    func signOut(){
        print("Sign out")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        HelperClass.userTypeRefernce.userID = "NIL"
        HelperClass.userTypeRefernce.userType = "NIL"
        print("Signing Out " + HelperClass.userTypeRefernce.userID + " " + HelperClass.userTypeRefernce.userType)
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.signOut()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
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
    
    @IBAction func createBookingsTapped(_ sender: Any) {
        if HelperClass.userTypeRefernce.userType == "Admin" || HelperClass.userTypeRefernce.userType == "Receptionist" {
            print("Perfrom Segue")
            performSegue(withIdentifier: "toCreateBooking", sender: self)
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
