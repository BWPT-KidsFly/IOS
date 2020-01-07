//
//  TripTableViewCell.swift
//  KidsFly
//
//  Created by Craig Swanson on 1/5/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import UIKit

//  The basic custom cell with a few items to use for testing purposes.

class TripTableViewCell: UITableViewCell {
    
    var trip: Trip? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var airlineLabel: UILabel!
    @IBOutlet weak var airportLabel: UILabel!
    @IBOutlet weak var kidsLabel: UILabel!
    @IBOutlet weak var flightLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        guard let trip = trip else { return }
        
        airlineLabel.text = trip.airline
        airportLabel.text = trip.airport
        kidsLabel.text = String(trip.childrenQty)
        flightLabel.text = trip.flightNumber
    }

}
