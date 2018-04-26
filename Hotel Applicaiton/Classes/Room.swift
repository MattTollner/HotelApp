//
//  Room.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 17/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit

class Room {
    var Number : String
    var Price : String
    var RoomType : String
    var RoomState : String
    var RoomID : String
    
    
    init(dictionary: [String: AnyObject])
    {
        self.Number = dictionary["Number"] as! String
        self.Price  = dictionary["Price"] as! String
        self.RoomState = dictionary["RoomState"] as! String
        self.RoomType = dictionary["RoomType"] as! String
        self.RoomID = dictionary["RoomID"] as! String
    }
    
    func getDoublePrice() -> Double {
        return Double(self.Price)!        
    }
    
    func changeRoomState(index : Int){
        if(index == 0){
            self.RoomState = "Clean"
        } else {
            self.RoomState = "Unclean"
        }
    }
    
    func getDict() -> Dictionary<String, Any> {
        
        let dict = ["Number" : self.Number,
                    "Price" : self.Price ,
                    "RoomState" : self.RoomState,
                    "RoomType" : self.RoomType ,
                    "RoomID" : self.RoomID] as [String : Any]
        
        
        return dict
    }
   
 
    
}
