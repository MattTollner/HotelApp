//
//  Staff.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 18/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit

class Staff {
    var Forename : String
    var Sirname : String
    var Email : String
    var Address : String
    var Postcode : String
    var Phone : String
    var StaffType : String
    var StaffID : String
    
    
    init(dictionary: [String: AnyObject])
    {
        self.Forename = dictionary["Forename"] as! String
        self.Sirname  = dictionary["Sirname"] as! String
        self.Email = dictionary["Email"] as! String
        self.Address = dictionary["Address"] as! String
        self.Postcode = dictionary["Postcode"] as! String
        self.Phone = dictionary["Phone"] as! String
        self.StaffType = dictionary["StaffType"] as! String
        self.StaffID = dictionary["StaffID"] as! String
        
    }
    
    func getFullName() -> String{
        return self.Forename + " " + self.Sirname
    }
}
