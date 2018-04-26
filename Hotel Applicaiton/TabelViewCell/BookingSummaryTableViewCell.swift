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
       // priceLabel.text = String(roomPrice)
        if(roomTypeLabel.text == "Double Single") {
            print("Room Double Single")
            breakfastAmount = 5.0
        } else {
            print("Else hit breakfast now 10")
            breakfastAmount = 10
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func breakfastSegmetChanged(_ sender: Any) {
        
        if(breakfastSegment.selectedSegmentIndex == 0) {

                print("Room cost : " + String(roomPrice) + " plus cost of breakfast (5)")
                let doublePrice = roomPrice + 5.0
                print("New cost = " + String(describing: doublePrice))
               // priceLabel.text = "£" + String(describing: doublePrice)
                totalAmount = doublePrice
            
        } else {
            print("Else Hit")
            //priceLabel.text = "£" + String(roomPrice)
            totalAmount = roomPrice
        }
    }
}
