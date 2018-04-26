//
//  PaymentViewController.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 25/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Firebase
import Stripe
import Alamofire
import SendGrid

extension String {
    var isAlpha : Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
}

class PaymentViewController: UIViewController, STPPaymentContextDelegate {
    
    @IBOutlet weak var buttonOutet: UIButton!
    @IBOutlet weak var forenameLabel: UITextField!
    @IBOutlet weak var sirnameLabel: UITextField!
    @IBOutlet weak var confirmEmailLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var postcodeLabel: UITextField!
    @IBOutlet weak var addressLabel: UITextField!
    @IBOutlet weak var cityLabel: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var depositDescriptionLabel: UILabel!
    @IBOutlet weak var deskPaymentDescriptorLabel: UILabel!
    @IBOutlet weak var paymentAtDeskLabel: UILabel!
    @IBOutlet weak var footnoteLabel: UILabel!
    
    //Segue Vars
    var amount : Double = 0.0
    var poundAmount : Double = 0.0
    var fullAmount : Double = 0.0
    var roomIDs = [String]()
    var breakfastRoomIDs = [String]()
    var checkInDate : Date = Date()
    var checkOutDate : Date = Date()
    
    var paymentInPennys = 0
    var fullBookingCost = 0.0
    var depositAmount = 0.0
    var breakfastAmount = 0.0
    var deskPayment = 0.0
    
    let db = Firestore.firestore()
    
    //  let paymentTextField = STPPaymentCardTextField()
    var thePaymentContext = STPPaymentContext()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonOutet.isEnabled = false
        if depositAmount == 0 { //Payy all
            print("Pay now selected")
            depositLabel.text = "£0.0"
            paymentAtDeskLabel.text = "£0.0"
            depositDescriptionLabel.isEnabled = false
            paymentAtDeskLabel.isEnabled = false
            deskPaymentDescriptorLabel.isEnabled = false
            depositLabel.isEnabled = false
            amountLabel.text = "£" + String(fullBookingCost)
            footnoteLabel.isHidden = true
            paymentInPennys = Int((fullBookingCost * 100))
            print("Payment In Pennys : " + String(paymentInPennys))
        } else { //Pay deposit
            depositLabel.text = "£" + String(depositAmount)
            deskPayment = fullBookingCost - depositAmount
            paymentAtDeskLabel.text = "£" + String(deskPayment)
            amountLabel.text = "£" + String(fullBookingCost)
            depositDescriptionLabel.isEnabled = true
            paymentAtDeskLabel.isEnabled = true
            deskPaymentDescriptorLabel.isEnabled = true
            depositLabel.isEnabled = true
            footnoteLabel.isHidden = false
            paymentInPennys = Int((fullBookingCost * 100))
            print("Payment In Pennys : " + String(paymentInPennys))
        }
        
       // poundAmount = amount / 100
        //amountLabel.text = "£" + String(describing: fullBookingCost)
        self.buttonOutet.isHidden = false
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func testPayButton(_ sender: Any) {
        self.thePaymentContext.requestPayment()
    }

    func checkLabels( ) -> Bool{
        var isPass = true
        
        if(forenameLabel.text == ""){
            forenameLabel.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        } else {
            forenameLabel.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(forenameLabel.text?.isAlpha == false){
            forenameLabel.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            forenameLabel.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
       
        if(sirnameLabel.text == ""){
            sirnameLabel.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            sirnameLabel.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(sirnameLabel.text?.isAlpha == false){
            sirnameLabel.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            sirnameLabel.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(emailLabel.text == ""){
            emailLabel.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            emailLabel.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(confirmEmailLabel.text == ""){
            confirmEmailLabel.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            confirmEmailLabel.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(addressLabel.text == ""){
            addressLabel.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            addressLabel.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(postcodeLabel.text == ""){
            isPass = false
        }else {
            postcodeLabel.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(cityLabel.text == ""){
            cityLabel.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            return false
        }else {
            cityLabel.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(emailLabel.text != confirmEmailLabel.text){
            emailLabel.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            confirmEmailLabel.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            isPass = false
        }else {
            emailLabel.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
            confirmEmailLabel.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        }
        if(isPass){
            return true
        } else {
            return false
        }
        
        
        
    }
    
    @IBOutlet weak var confirmDetails: UIButton!
    @IBAction func confrimDetails(_ sender: Any) {
        //paymentTextField.isHidden = false
        
        if(checkLabels() == false){
            print("Incorrect Label Text")
        } else {
            
        
        
        
        let custDetails = [forenameLabel.text,
                           sirnameLabel.text,
                           emailLabel.text,
                           addressLabel.text,
                           postcodeLabel.text,
                           cityLabel.text]
        
        APIClient.customerDetails = custDetails as! [String]
        let config = STPPaymentConfiguration.shared()
        config.publishableKey = "pk_test_D5d9OgNCQ8OZStYlQNtDanFA"
        config.companyName = "Student Enterprises"
        
        let customerContext = STPCustomerContext(keyProvider: APIClient.sharedClient)
        let paymentContext = STPPaymentContext(customerContext: customerContext,
                                               configuration: config,
                                               theme: .default())
        paymentContext.paymentAmount = Int(paymentInPennys)
        paymentContext.paymentCurrency = "GBP"
        
        self.thePaymentContext = paymentContext
        self.thePaymentContext.delegate = self
        paymentContext.hostViewController = self
        paymentContext.pushPaymentMethodsViewController()
        
        forenameLabel.isEnabled = false
        sirnameLabel.isEnabled = false
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("DID FAIL TO LOAD WITH ERROR")
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            paymentContext.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        print("Hello")
        
        if APIClient.customerOkay == true {
            print("CUSOTMER OKAY :: Ready to pay")
            buttonOutet.isEnabled = true
        } else {
            buttonOutet.isEnabled = false
        }
       
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        print("DID FINISH WITH STATUS")
        let title: String
        var message: String = ""
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            
            let customerDict : [String : Any] = ["Forename" : forenameLabel.text! ,
                                                 "Sirname" : sirnameLabel.text!,
                                                 "Email" : emailLabel.text!,
                                                 "Address" : addressLabel.text!,
                                                 "Postcode" : postcodeLabel.text!,
                                                 "City" : cityLabel.text!]
            
   
            let db = Firestore.firestore()
            var ref: DocumentReference? = nil
            var cID = ""
            var bID = ""
            ref = db.collection("Customer").addDocument(data: customerDict) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Customer added reference : " + (ref?.documentID)!)
                    cID = (ref?.documentID)!
                    //ADDING BOOKING
                    var cost = 0.0
                    if(self.depositAmount == 0){
                        cost = self.fullBookingCost
                    } else {
                        cost = self.depositAmount
                    }
                    var bookingDict : [String: Any] = ["BookingDate" : "",
                                                       "CheckIn" : self.checkInDate,
                                                       "CheckOut" : self.checkOutDate,
                                                       "CustomerID" : cID,
                                                       "RoomID" : self.roomIDs,
                                                       "Breakfast" : self.breakfastRoomIDs ,
                                                       "TotalAmount" : self.fullBookingCost,
                                                       "AmountPayed" : cost,
                                                       "Status" : "Booked",
                                                       "BookingID" : bID]
                    var ref2: DocumentReference? = nil
                    ref2 = db.collection("Booking").addDocument(data: bookingDict) {err in
                        if let err = err {
                            print("Error Adding Booking : \(err)")
                        } else {
                            print("Booking Successfully Added :: Booking refernce : " + (ref2?.documentID)!)
                            
                            if let bRef = ref2?.documentID {
                                bID = bRef
                                 self.formEmail(bookingID: bID)
                            } else {
                               print("Optional Unwrapped Found Nil")
                            }
                            bookingDict =  ["BookingDate" : "",
                             "CheckIn" : self.checkInDate,
                             "CheckOut" : self.checkOutDate,
                             "CustomerID" : cID,
                             "RoomID" : self.roomIDs,
                             "Breakfast" : self.breakfastRoomIDs ,
                             "TotalAmount" : self.fullBookingCost,
                             "AmountPayed" : cost,
                             "Status" : "Booked",
                             "BookingID" : bID]
                            
                            db.collection("Booking").document(bID).setData(bookingDict) { (error) in
                                if let error = error {
                                    print("Error updating booking (ID not set): \(error)")
                                } else {
                                    print("Booking ID updated stored id: \(bID)")
                                    self.performSegue(withIdentifier: "unwindBooking", sender: self)
                                }
                            }
                        }
                    }
                }
            }
            title = "Succes you booked a room!"
        case .userCancellation:
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func formEmail(bookingID : String){
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
            "senderEmail" : "matt.tollner@live.co.uk",
            "bookingRef" : bookingID
            
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
    
    func paymentContext(_ paymentContext : STPPaymentContext, didCreatePaymentResult paymentResult : STPPaymentResult, completion : @escaping STPErrorBlock){
        print("DID CREATE PAYMENT :: amount : " + String(paymentInPennys))
        
        APIClient.sharedClient.completeCharge(paymentResult,
                                              amount: Int(paymentInPennys),
                                              shippingAddress: nil,
                                              shippingMethod: nil,
                                              completion: completion)
    }
    
}
