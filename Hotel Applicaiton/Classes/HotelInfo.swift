//
//  HotelInfo.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 26/04/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import Foundation

class HotelInfo {
    var Address : String
    var Breakfast : String
    var CheckIn : String
    var CheckOut : String
    var Email : String
    var Phone : String
    
    
    init(dictionary: [String: AnyObject])
    {
        self.Address = dictionary["Address"] as! String
        self.Breakfast  = dictionary["Breakfast"] as! String
        self.CheckIn = dictionary["CheckIn"] as! String
        self.CheckOut = dictionary["CheckOut"] as! String
        self.Email = dictionary["Email"] as! String
        self.Phone  = dictionary["Phone"] as! String
    }
    
    func getDict() -> Dictionary<String, Any> {
        
        let dict = ["Address" : self.Address,
                    "Breakfast" : self.Breakfast ,
                    "CheckIn" : self.CheckIn,
                    "CheckOut" : self.CheckOut ,
                    "Email" : self.Email ,
                    "Phone" : self.Phone
                   ]
        
        
        return dict
    }
    
    
}
