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

class HotelMainPageViewController: UIViewController {

    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
