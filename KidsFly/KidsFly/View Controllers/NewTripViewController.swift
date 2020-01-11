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
    var bearer: Bearer?
    var tripController: TripController?
    var kfConnectionController: KFConnectionController?
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
        
        // updateViews looks to see if there is an existing trip, in which case it populates the elements with that trip data.
        updateViews()
    }
    
    // MARK: - Actions
    @IBAction func addNewTripButtonTapped(_ sender: Any) {

        guard let tripController = tripController,
            let bearer = bearer
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
            
            // The first part of the if let looks for an existing trip.  If there is one, it uses the identifier of that trip so it doesn't duplicate it on the server.
            // TODO:  when moving to the production backend, this is duplicating it on the server.
            if let trip = trip {
                trip.airport = airport
                trip.airline = airline
                trip.flightNumber = flightNumber
                trip.departureTime = departureTimePicker.date
                trip.childrenQty = Int16(childrenQty)!
                trip.carryOnQty = Int16(carryOnQty)!
                trip .checkedBagQty = Int16(checkedBagQty)!
                trip.notes = notesTextView.text
                
                tripController.updateExistingTrip(for: bearer, trip: trip)
                
                // Present alert to user to confirm successful change in the trip.
                let alertController = UIAlertController(title: "Trip Updated", message: "Your trip was successfully changed.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(alertAction)
                self.present(alertController, animated: true)
            
                // If there is not an existing trip, a newTrip is created and sent to the put method, which puts it on the server and saves to core data.
                // The put method is used for new trips and updating trips, and they have different HTTPMethods on the back end, so the correct value is passed.
            } else {
                let newTrip = Trip(airport: airport, airline: airline, flightNumber: flightNumber, departureTime: departureTimePicker.date, childrenQty: Int16(childrenQty)!, carryOnQty: Int16(carryOnQty)!, checkedBagQty: Int16(checkedBagQty)!, notes: notesTextView.text)
                tripController.put(traveler: bearer, trip: newTrip, method: HTTPMethod.post) { error in
                    if error != .success(true) {
                        print("Error occurred while PUTin a new trip to server: \(error)")
                    } else {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "New Trip Added", message: "Your new trip was created.", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
                                self.dismiss(animated: true, completion: nil)
                                self.navigationController?.popViewController(animated: true)
                            }
                            alertController.addAction(alertAction)
                            self.present(alertController, animated: true)
                        }
                    }
                }
            }
            
        }
    }
    
    // MARK: - Toggle Trip Completion
    
    // UpdateExistingTrip is called, which in turn calls the put method with the PUT HTTPMethod.
    @IBAction func toggleTripCompletionStatus(_ sender: UIButton) {
        guard let trip = trip,
        let bearer = bearer else { return }
        trip.completedStatus.toggle()
        tripController?.updateExistingTrip(for: bearer, trip: trip)
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Update Views
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
