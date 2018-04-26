//
//  APIClient.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 05/03/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
import Stripe
import Alamofire

class APIClient : NSObject, STPEphemeralKeyProvider {
    
    let stripePublishableKey = "pk_test_D5d9OgNCQ8OZStYlQNtDanFA"
    static var customerOkay = false
    
    // 2) Next, optionally, to have this demo save your user's payment details, head to
    // https://github.com/stripe/example-ios-backend , click "Deploy to Heroku", and follow
    // the instructions (don't worry, it's free). Replace nil on the line below with your
    // Heroku URL (it looks like https://blazing-sunrise-1234.herokuapp.com ).
    let backendBaseURL: String? = "https://evening-garden-46354.herokuapp.com"
    
    
    static var customerDetails : [String] = []
    static let sharedClient = APIClient()
    var baseURLString: String? = "https://evening-garden-46354.herokuapp.com"
    var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }
    
    func createCustomer(completion: @escaping STPErrorBlock) {
        let url = self.baseURL.appendingPathComponent("createCustomer")
        var email = "matt.tollner@live.co.uk"
        
        var params: [String: Any] = [
            "email": "matt.tollner@live.co.uk"
        ]
        
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
        
    }
    
    func completeCharge(_ result: STPPaymentResult,
                        amount: Int,
                        shippingAddress: STPAddress?,
                        shippingMethod: PKShippingMethod?,
                        completion: @escaping STPErrorBlock) {
        print("completeChargeCalled !! !! !! !!")
        let url = self.baseURL.appendingPathComponent("charge")
        print("Charge amoutn " + String(amount))
        var params: [String: Any] = [
            "customer": "cus_CQrqx8Vh5ay4Gb",
            "amount": amount,
            "currency" : "GBP"
        ]
        params["shipping"] = STPAddress.shippingInfoForCharge(with: shippingAddress, shippingMethod: shippingMethod)
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        print("createCustomerKey Called!")
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")

        
        Alamofire.request(url, method: .post, parameters: [
            "api_version": apiVersion,
            "customerEmail" : APIClient.customerDetails[2],
            "Forename" : APIClient.customerDetails[0],
            "Sirname" : APIClient.customerDetails[1],
            "Address" : APIClient.customerDetails[3],
            "City" : APIClient.customerDetails[5],
            "Postcode" : APIClient.customerDetails[4]
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                    APIClient.customerOkay = true
                    print("SUCCESS :: EPHEMERAL KEYS ::")
                case .failure(let error):
                    completion(nil, error)
                    APIClient.customerOkay = false
                    print("FAILURE :: EPHEMERAL KEYS :: " + error.localizedDescription)
                }
        }
    }
    
}
