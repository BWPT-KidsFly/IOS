//
//  NewTripViewController.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/26/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import UIKit

// TODO: Add a required MVP button to alert KidsConnection when user is 5 minutes from airport and again when they have arrived at airport.

// This view is for an existing user to enter the required details regarding a new trip.  It is also used to edit details of an existing trip or to mark the status as completed.

class NewTripViewController: UIViewController {
    
    // MARK: - Properties
    var travelerController: TravelerController?
    var tripController: TripController?
    var trip: Trip? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var airlineTextField: UITextField!
    @IBOutlet weak var airportTextField: UITextField!
    @IBOutlet weak var carryOnQtyPicker: UITextField!
    @IBOutlet weak var checkedBagQtyPicker: UITextField!
    @IBOutlet weak var childrenQtyPicker: UITextField!
    @IBOutlet weak var departureTimePicker: UIDatePicker!
    @IBOutlet weak var flightNumberTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var markAsCompletedButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
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
            
            // The first part of the if let looks for an existing trip.  If there is one, it uses the identifier of that trip so it doesn't duplicate it on the server. There is an issue though in that it creates a new version in core data while simply updating it on the server.  I probably need to call an "updateTrip" method rather than the "put" method.
            if let trip = trip {
                trip.airport = airport
                trip.airline = airline
                trip.flightNumber = flightNumber
                trip.departureTime = departureTimePicker.date
                trip.childrenQty = Int16(childrenQty)!
                trip.carryOnQty = Int16(carryOnQty)!
                trip .checkedBagQty = Int16(checkedBagQty)!
                trip.notes = notesTextView.text
                
                tripController.updateExistingTrip(for: traveler, trip: trip)
                
                let alertController = UIAlertController(title: "Trip Updated", message: "Your trip was successfully changed.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(alertAction)
                self.present(alertController, animated: true)
            
                
//                { error in
//                    if error != .success(true) {
//                        print("Error occurred while PUTin a new trip to server: \(error)")
//                    } else {
//                        DispatchQueue.main.async {
//                            let alertController = UIAlertController(title: "Trip Updated", message: "Your trip was successfully changed.", preferredStyle: .alert)
//                            let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
//                                self.dismiss(animated: true, completion: nil)
//                            }
//                            alertController.addAction(alertAction)
//                            self.present(alertController, animated: true)
//                        }
//                    }
//                }
            } else {
                let newTrip = Trip(airport: airport, airline: airline, flightNumber: flightNumber, departureTime: departureTimePicker.date, childrenQty: Int16(childrenQty)!, carryOnQty: Int16(carryOnQty)!, checkedBagQty: Int16(checkedBagQty)!, notes: notesTextView.text)
                tripController.put(traveler: traveler, trip: newTrip) { error in
                    if error != .success(true) {
                        print("Error occurred while PUTin a new trip to server: \(error)")
                    } else {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "New Trip Added", message: "Your new trip was created.", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
                                self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(alertAction)
                            self.present(alertController, animated: true)
                        }
                    }
                }
            }
            
        }
    }
    
    @IBAction func toggleTripCompletionStatus(_ sender: UIButton) {
        guard let trip = trip,
        let travelerController = travelerController,
            let traveler = travelerController.traveler else { return }
        trip.completedStatus.toggle()
        tripController?.updateExistingTrip(for: traveler, trip: trip)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        if let trip = trip {
            title = trip.flightNumber
            airlineTextField.text = trip.airline
            airportTextField.text = trip.airport
            carryOnQtyPicker.text = String(trip.carryOnQty)
            checkedBagQtyPicker.text = String(trip.checkedBagQty)
            childrenQtyPicker.text = String(trip.childrenQty)
            flightNumberTextField.text = trip.flightNumber
            notesTextView.text = trip.notes
            departureTimePicker.date = trip.departureTime!
        } else {
        title = "Create New Trip"
            markAsCompletedButton.isEnabled = false
            markAsCompletedButton.setTitleColor(UIColor.systemGray, for: .disabled)
        }
    }
}
