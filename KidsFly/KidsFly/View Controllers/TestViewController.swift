//
//  TestViewController.swift
//  KidsFly
//
//  Created by Craig Swanson on 1/3/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    var tripController = TripController()
    var travelerController = TravelerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TravelerSegue" {
            guard let newTravelerVC = segue.destination as? TravelerSignUpViewController else { return }
            newTravelerVC.tripController = tripController
            newTravelerVC.travelerController = travelerController
        }
    }

}
