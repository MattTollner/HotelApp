//
//  HotelMainPageViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 27/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import SendGrid
import Alamofire
import Firebase

class HotelMainPageViewController: UIViewController {

    
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkOutLabel: UILabel!
    @IBOutlet weak var breakfastTimeLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    @IBOutlet weak var phoneStack: UIStackView!
    
    @IBOutlet weak var infoStack: UIStackView!
    
    var hotelInfo : HotelInfo?
    var db : Firestore?
    
    @IBOutlet weak var breakfastLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        disableElements()
        activityIndicator.startAnimating()
        loadingLabel.isHidden = false
        db = Firestore.firestore()
        retriveInformation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func enableElements(){
        print("enabling elements")
        infoStack.isHidden = false
        activityIndicator.stopAnimating()
        loadingLabel.isHidden = true
        activityIndicator.isHidden = true
        addressTextView.isHidden = false
        
        reloadInputViews() 
    }
    
    func disableElements(){
        print("disabling elements")
        infoStack.isHidden = true
        addressTextView.isHidden = true
    }
   
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        print("Home page moved")
        APIClient.customerOkay = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func testEmailButton(_ sender: Any) {
        formEmail()
    }
    func formEmail(){
        var baseURLString: String? = "https://evening-garden-46354.herokuapp.com"
        var baseURL: URL {
            if let urlString = baseURLString, let url = URL(string: urlString) {
                return url
            } else {
                fatalError()
            }
        }
        
        let url = baseURL.appendingPathComponent("email")
        
        
        Alamofire.request(url, method: .post, parameters: [

            "customerEmail" : "matt.tollners@gmail.com",
            "senderEmail" : "matt.tollner@live.co.uk"
         
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                 //   completion(json as? [String: AnyObject], nil)
                    print("SUCCESS :: Email Sent ::")
                case .failure(let error):
                   // completion(nil, error)
                    print("FAILURE :: Email Failed :: " + error.localizedDescription)
                }
        }
    }
    
    func retriveInformation(){
        print("Retriving Info")
        disableElements()
        db?.collection("HotelInfo").getDocuments { (snapshot, error) in
            if let error = error {
                //print("Error getting documents: \(error)")
                self.fireError(titleText: "Error retriving hotel information", lowerText: error.localizedDescription)
                self.activityIndicator.stopAnimating()
                self.loadingLabel.isHidden = true
            } else {
                for document in snapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.hotelInfo = HotelInfo(dictionary: document.data() as [String : AnyObject])
                    self.populateInformation()
                }
                
                self.activityIndicator.stopAnimating()
                self.loadingLabel.isHidden = true
            }
        }
    }
        
        func populateInformation(){
            print("Populating Info")
            enableElements()
            if let hotel = hotelInfo{
                HelperClass.hotelInfo = hotel
                addressTextView.text = hotel.Address
                emailLabel.text = hotel.Email
                phoneLabel.text = hotel.Phone
                breakfastTimeLabel.text = hotel.Breakfast
                checkInLabel.text = hotel.CheckIn
                checkOutLabel.text = hotel.CheckOut
            } else {
                print("hotel blank")
            }
            
        }
    
    


    
}

