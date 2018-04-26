//
//  RoomCleaningTableViewCell.swift
//  Hotel Applicaiton
//
//  Created by Matthew Tollner on 27/02/2018.
//  Copyright © 2018 Matthew Tollner. All rights reserved.
//

import UIKit

class RoomCleaningTableViewCell: UITableViewCell {

    @IBOutlet weak var roomTypeLabel: UILabel!
    @IBOutlet weak var roomStatusLabel: UILabel!
    @IBOutlet weak var roomNumberLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
