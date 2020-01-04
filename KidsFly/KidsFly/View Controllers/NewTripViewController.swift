//
//  NewTripViewController.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/26/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import UIKit

class NewTripViewController: UIViewController {
    
    // MARK: - Properties
    var travelerController: TravelerController?
    var tripController: TripController?
    
    // MARK: - Outlets
    @IBOutlet weak var airlineTextField: UITextField!
    @IBOutlet weak var airportTextField: UITextField!
    @IBOutlet weak var carryOnQtyPicker: UITextField!
    @IBOutlet weak var checkedBagQtyPicker: UITextField!
    @IBOutlet weak var childrenQtyPicker: UITextField!
    @IBOutlet weak var departureTimePicker: UIDatePicker!
    @IBOutlet weak var flightNumberTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @IBAction func addNewTripButtonTapped(_ sender: Any) {
        guard let travelerController = travelerController,
            let tripController = tripController,
            let traveler = travelerController.traveler
            else { return }
        if let airline = airlineTextField.text,
            !airline.isEmpty,
            let airport = airportTextField.text,
            !airport.isEmpty,
            let carryOnQty = carryOnQtyPicker.text,
            !carryOnQty.isEmpty,
            let checkedBagQty = checkedBagQtyPicker.text,
            !checkedBagQty.isEmpty,
            let childrenQty = childrenQtyPicker.text,
            !childrenQty.isEmpty,
            let flightNumber = flightNumberTextField.text,
            !flightNumber.isEmpty {
            
            let newTrip = Trip(airport: airport, airline: airline, flightNumber: flightNumber, departureTime: departureTimePicker.date, childrenQty: Int16(childrenQty)!, carryOnQty: Int16(carryOnQty)!, checkedBagQty: Int16(checkedBagQty)!, notes: notesTextView.text)
            
            let representation = newTrip.tripRepresentation
            
            
            tripController.put(traveler: traveler, trip: representation) { result in
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "New Trip Added", message: "Your new trip was created.", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
