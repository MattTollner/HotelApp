//
//  Booking.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 19/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit
//import Firebase

class Booking {
    var RoomID : [String]
    var CustomerID : String
    var BookingDate : String
    var CheckIn : Date
    var CheckOut : Date
    //var CheckInStamp : Timestamp
    //var CheckOutStamp : Timestamp
    var BookingStatus : String
    var TotalAmount : Double
    var AmountPayed : Double
    var Breakfast : [String]
    var BookingID : String
    
    
    init(dictionary: [String: AnyObject])
    {
        self.RoomID = dictionary["RoomID"] as! [String]
        self.CustomerID  = dictionary["CustomerID"] as! String
        self.BookingDate = dictionary["BookingDate"] as! String
        // self.CheckInStamp = dictionary["CheckIn"] as! Timestamp
        //  self.CheckOutStamp = dictionary["CheckOut"] as! Timestamp
        self.BookingStatus = dictionary["Status"] as! String
        self.TotalAmount = dictionary["TotalAmount"] as! Double
        self.Breakfast = dictionary["Breakfast"] as! [String]
        self.AmountPayed = dictionary["AmountPayed"] as! Double
        self.BookingID = dictionary["BookingID"] as! String
        self.CheckIn = dictionary["CheckIn"] as! Date
        self.CheckOut = dictionary["CheckOut"] as! Date
        // self.CheckIn = self.CheckInStamp.dateValue()
        // self.CheckOut = self.CheckOutStamp.dateValue()
        
    }
    
    
    func checkAvailability(sDate : String, nights : String) -> Bool{
        
        //Check Status
        
        if(self.BookingStatus == "Cancelled" || self.BookingStatus == "CheckedOut" || self.BookingStatus == "Checked Out" ){
            print("TRUE: ")
            return true
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            var dateComponent2 = DateComponents ()
            dateComponent2.minute = 600
            var StartB = dateFormatter.date(from: sDate)
            StartB = Calendar.current.date(byAdding: dateComponent2, to: StartB!)
            var dateComponent = DateComponents ()
            dateComponent.day = Int(nights)
            
            let EndB = Calendar.current.date(byAdding: dateComponent, to: StartB!)
            
            
            if(self.CheckOut <= StartB! && self.CheckIn <= StartB!){
                print("FIRED ONE")
            }
            
            
            if(self.CheckOut <= StartB! && self.CheckIn < StartB!){
                print("FIRED TWO")
            }
            if(self.CheckOut <= StartB! && self.CheckIn == StartB!){
                print("FIRED FOUR")
            }
            
            
            if(self.CheckIn <= EndB!) && (self.CheckOut >= StartB!){
                print("FIRED 3")
            }
            //< less than
            if(self.CheckIn <= EndB!) && (self.CheckOut >= StartB!)
            {
                
                
                let isIT = Calendar.current.isDate(self.CheckOut, inSameDayAs: StartB!)
                print("BOOKING NOT AVAILBLE " + String(isIT))
                
                //  print(" BOOKING CLASS Unable to book room")
                //Rooms not available
                return false
                
            } else
            {
                print("Did not match criteria")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy" //Your date format
                
                var stringDate = dateFormatter.string(from: (StartB!))
                
                print("SELF CheckIN :: " + self.getCheckIn() + " NEW CheckIn :: "
                    + stringDate)
                
                stringDate = dateFormatter.string(from: (EndB!))
                
                print("SELF CheckOut :: " + self.getCheckOut() + " NEW CheckIn :: "
                    + stringDate)
                
                
                if(self.CheckIn >= StartB!){
                    print("Self.checkIN Greater than/= StartB")
                } else {
                    print("Self.checkIN LESS THAN than/= StartB")
                }
                
                if(self.CheckOut <= EndB!){
                    print("Self.checkOut LESS than/= ENDB")
                } else {
                    print("Self.checkOUT GREATER than/= ENdB")
                }
                
                if (self.CheckIn >= StartB!) && (self.CheckOut <= EndB!)
                {
                    print("NEW BOOKING OVERLAP ENTIRE")
                    return false
                }else {
                    print("Match booking available")
                    
                    return true
                }
                
            }
            
            
            
        }
    }
    
    func getDict() -> Dictionary<String, Any> {
        
        let dict = ["BookingDate" : self.BookingDate,
                    "CheckIn" : self.CheckIn ,
                    "CheckOut" : self.CheckOut,
                    "CustomerID" : self.CustomerID ,
                    "RoomID" : self.RoomID,
                    "Breakfast" : self.Breakfast ,
                    "TotalAmount" : self.TotalAmount,
                    "AmountPayed" : self.AmountPayed,
                    "Status" : self.BookingStatus,
                    "BookingID" : self.BookingID] as [String : Any]
        
        
        return dict
    }
    
    func setBookingState(state: Int){
        print("CLASS :: Setting booking status")
        switch state {
        case 0:
            print("Setting Status To Booked")
            self.BookingStatus = "Booked"
        case 1:
            print("Setting Status to CheckedIn")
            self.BookingStatus = "Checked In"
        case 2:
            self.BookingStatus = "Checked Out"
        case 3:
            self.BookingStatus = "Cancelled"
        default:
            print("Error Hit Default")
            self.BookingStatus = "ERROR HIT DEFUALT"
        }
    }
    
    func getCheckIn() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" //Your date format
        
        let stringDate = dateFormatter.string(from: (self.CheckIn))
        
        return stringDate
    }
    
    func getCheckOut() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" //Your date format
        
        let stringDate = dateFormatter.string(from: (self.CheckOut))
        
        return stringDate
    }
    
    func getAmountPayed() -> String{
        let stringNum = String(self.AmountPayed)
        return stringNum
    }
    
    func getTotalAmount() -> String{
        let stringNum = String(self.TotalAmount)
        return stringNum
    }
    
    func hasPayedFull() -> Bool{
        
        if(self.AmountPayed == self.TotalAmount){
            return true
        } else {
            return false
        }
    }
    
    func payFull(){
        self.AmountPayed = self.TotalAmount
    }
    
    func getAmountPayedDisplay() -> String{
        let aPay = "£" + String(self.AmountPayed)
        return aPay
    }
    func getTotalAmountDisplay() -> String{
        let aPay = "£" + String(self.TotalAmount)
        return aPay
    }
}

