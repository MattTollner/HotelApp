//
//  Customer.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 19/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit

class Customer {

    var Forename : String
    var Sirname : String
    var Email   : String
    var Address : String
    var Postcode : String
    
    
    
    init(dictionary: [String: AnyObject])
    {
        self.Forename = dictionary["Forename"] as! String
        self.Sirname  = dictionary["Sirname"] as! String
        self.Email = dictionary["Email"] as! String
        self.Address = dictionary["Address"] as! String
        self.Postcode = dictionary["Postcode"] as! String
    }
    
    func getFullName() -> String{
        return (Forename + " " + Sirname)
    }
    
    
    
}
