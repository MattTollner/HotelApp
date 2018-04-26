//
//  ManageBookingTableViewCell.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 01/03/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit

class ManageBookingTableViewCell: UITableViewCell {
  
  
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkOutLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
