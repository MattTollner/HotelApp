//
//  BookingRoomTableViewCell.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 18/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit

class BookingRoomTableViewCell: UITableViewCell {

    
    @IBOutlet weak var roomIteration: UILabel!

    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var roomTypeLabel: UILabel!
    @IBOutlet weak var priceTextField: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stepper.value = 0
        roomTypeLabel.text = "Single"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateTable(){
        //BookingViewController().updateTheTable()
    }
    @IBAction func stepperTapped(_ sender: Any) {
        switch stepper.value {
        case 0.0:
            roomTypeLabel.text = "Single"
        case 1.0:
            roomTypeLabel.text = "Double Single"
        case 2.0:
            roomTypeLabel.text = "Double"
        case 3.0:
            roomTypeLabel.text = "Family"
        default:
            roomTypeLabel.text = "Single"
            print("Problem Default hit")
        }
        
        self.reloadInputViews()
        print("Inside the cell " + String(stepper.value))
        
        
    }
   
    
}
