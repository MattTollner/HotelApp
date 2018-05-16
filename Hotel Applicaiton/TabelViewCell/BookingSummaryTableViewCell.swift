//
//  BookingSummaryTableViewCell.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 08/03/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit

class BookingSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var roomIteration: UILabel!
    @IBOutlet weak var roomTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var breakfastSegment: UISegmentedControl!
    var roomPrice = 0.0
    var breakfastAmount = 0.0
    var totalAmount = 0.0
    var breakfastRoomIDs = [String]()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("Awoke frfom nib " + String(roomPrice))
        priceLabel.text = String(roomPrice)
        setBAmount()
        updateValues()
        
    }
    
    func setBAmount(){
        if(roomTypeLabel.text == "Double Single") {
            print("Room Double Single")
            breakfastAmount = 10.0
        } else if (roomTypeLabel.text == "Single") {
            print("Single breakfast now 5")
            breakfastAmount = 5.0
        } else if (roomTypeLabel.text == "Double") {
            print("Double breaksft 10")
            breakfastAmount = 10.0
        }else if (roomTypeLabel.text == "Family") {
            print("Family breakfast 20")
            breakfastAmount = 20.0
        } else {
            print("Else hit breakfast defaulat 10")
            breakfastAmount = 10.0
        }
    }
    
    func updateValues(){
        //Breakfast
        if(breakfastSegment.selectedSegmentIndex == 0) {
            totalAmount = (roomPrice + breakfastAmount)
            print("Setting Price Label :: " + String(totalAmount)   )
            //priceLabel.text = String(totalAmount)
            
        } else {
            totalAmount = roomPrice
            print("Setting Price Label NO BREAKFAST :: " + String(totalAmount))
            //priceLabel.text = String(totalAmount)
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func breakfastSegmetChanged(_ sender: Any) {
        setBAmount()
        updateValues()
       
    }

}
