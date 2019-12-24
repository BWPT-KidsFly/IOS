//
//  TravelerSignUpViewController.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/18/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import UIKit

class TravelerSignUpViewController: UIViewController {
    
    // MARK: - Properties
    var travelerController: TravelerController?
    
    @IBOutlet weak var airportTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let travelerController = travelerController else { return }
        if let airport = airportTextField.text,
            !airport.isEmpty,
            let city = cityTextField.text,
            !city.isEmpty,
            let firstName = firstNameTextField.text,
            !firstName.isEmpty,
            let lastName = lastNameTextField.text,
            !lastName.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty,
            let phoneNumber = phoneNumberTextField.text,
            !phoneNumber.isEmpty,
            let state = stateTextField.text,
            !state.isEmpty,
            let street = streetTextField.text,
            !street.isEmpty,
            let username = usernameTextField.text,
            !username.isEmpty,
            let zipCode = zipCodeTextField.text,
            !zipCode.isEmpty {
            
            let traveler = Traveler(username: username, password: password, firstName: firstName, lastName: lastName, streetAddress: street, cityAddress: city, stateAddress: state, zipCode: zipCode, phoneNumber: phoneNumber, airport: airport)
            
            let representation = TravelerRepresentation(identifier: traveler.identifier?.uuidString, username: traveler.username!, password: traveler.password!, firstName: traveler.firstName, lastName: traveler.lastName, streetAddress: traveler.streetAddress, cityAddress: traveler.cityAddress, stateAddress: traveler.stateAddress, zipCode: traveler.zipCode, phoneNumber: traveler.phoneNumber, airport: traveler.airport)
            
            travelerController.signUp(with: representation) { error in
                if let error = error {
                    print("Error occurred during sign up: \(error)")
                } else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Sign Up Successful", message: "Your account was created, please log in to continue.", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }

}

