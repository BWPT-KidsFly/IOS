//
//  TripTableViewCell.swift
//  KidsFly
//
//  Created by Craig Swanson on 1/5/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {
    
    var trip: Trip? {
        didSet {
            updateViews()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        
    }

}
