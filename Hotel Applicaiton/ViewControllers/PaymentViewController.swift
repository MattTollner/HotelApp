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
    
    //UI Elements
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
    @IBOutlet weak var bottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var elementsStack: UIStackView!
    @IBOutlet weak var priceStack: UIStackView!
    
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
    var moveUpAmount = 0.0
    
    let db = Firestore.firestore()
    var thePaymentContext = STPPaymentContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Keyboard observer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
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
        
      
        self.buttonOutet.isHidden = false
       
        //Tool bar setup
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([doneButton], animated: true)
        
        forenameLabel.inputAccessoryView = toolBar
        sirnameLabel.inputAccessoryView = toolBar
        emailLabel.inputAccessoryView = toolBar
        addressLabel.inputAccessoryView = toolBar
        confirmEmailLabel.inputAccessoryView = toolBar
        postcodeLabel.inputAccessoryView = toolBar
        cityLabel.inputAccessoryView = toolBar
        
    }
    
    //Move view up
    @objc func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            print("KEYBOARD ADJUST")
            enableElements(enable: false)
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
                print("MOVE UP AMOUNT :: " + String(self.moveUpAmount))
                self.bottonConstraint.constant = (rect.height + 20)
            }
        }
    }
    
    //Move view to orig
    @objc func keyboardWillHide(notification: NSNotification) {
        if let info = notification.userInfo {
            self.view.layoutIfNeeded()
            enableElements(enable: true)
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
                self.bottonConstraint.constant = 87
            }
        }
    }
    
    
    
    func enableElements(enable : Bool){
        if enable {
            elementsStack.isHidden = false
            priceStack.isHidden = false
        } else {
            elementsStack.isHidden = true
            priceStack.isHidden = true
        }
    }
    
    @objc func doneClicked(){
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
   
    //Pay pressed get stripe context
    @IBAction func testPayButton(_ sender: Any) {
        self.thePaymentContext.requestPayment()
    }

    func checkLabels( ) -> Bool{
        var isPass = true
        
        forenameLabel.text  = forenameLabel.text?.replacingOccurrences(of: " ", with: "")
        sirnameLabel.text  = sirnameLabel.text?.replacingOccurrences(of: " ", with: "")
        emailLabel.text  = emailLabel.text?.replacingOccurrences(of: " ", with: "")
        confirmEmailLabel.text  = confirmEmailLabel.text?.replacingOccurrences(of: " ", with: "")
        
        
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
                     self.fireError(titleText: "Error adding customer", lowerText: err.localizedDescription)
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
                            self.fireError(titleText: "Error adding booking", lowerText: err.localizedDescription)
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
                                     self.fireError(titleText: "Error setting booking data", lowerText: error.localizedDescription)
                                } else {
                                    print("Booking ID updated stored id: \(bID)")
                                    
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
        let alertController = UIAlertController(title: title, message: "Email summary sent to " + emailLabel.text!, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { action in
            self.performSegue(withIdentifier: "unwindBooking", sender: self)
        }
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let checkIn = dateFormatter.string(from: self.checkInDate)
        let checkOut = dateFormatter.string(from: self.checkOutDate)
        
        print("CHECK IN : " + checkIn + " Checkout " + checkOut)
        let nameC = forenameLabel.text! + " " + sirnameLabel.text!
        Alamofire.request(url, method: .post, parameters: [
            
            "customerEmail" : emailLabel.text!,
            "senderEmail" : emailLabel.text!,
            "bookingRef" : bookingID,
            "totalAmount" : self.fullAmount,
            "amountPayed" : self.depositAmount,
            "checkInDate" : checkIn,
            "checkOutDate" : checkOut,
            "name": nameC,
            
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
