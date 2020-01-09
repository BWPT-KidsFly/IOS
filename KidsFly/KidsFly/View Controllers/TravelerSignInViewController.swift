//
//  TravelerSignInViewController.swift
//  KidsFly
//
//  Created by Craig Swanson on 1/6/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import UIKit

//  This idea behind this view is that is accessed when launching the app and provides the user a username and password field to login. There is also a new user registration button to tap if the user does not yet have proper credentials.

class TravelerSignInViewController: UIViewController {
    
    var travelerController: TravelerController?
    var tripController: TripController?
    var traveler: TravelerRepresentation? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var newUserLabel: UILabel!
    @IBOutlet weak var userTypeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViews()
    }
    
    @IBAction func userTypeChanged(_ sender: UISegmentedControl) {
    }
    
    @IBAction func userRegistrationButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "UserRegistrationSegue", sender: self)
    }
    
    @IBAction func userSignIn(_ sender: UIButton) {
        guard let travelerController = travelerController else { return }
//            let traveler = traveler else { return }
        if let username = usernameTextField.text,
            !username.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty {
            let travelerLogIn = TravelerLogIn(username: username, password: password)
            travelerController.logIn(with: travelerLogIn) { error in
                if let error = error {
                    print("Error occurred during logging in: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserRegistrationSegue" {
            guard let travelerSignUpVC = segue.destination as? TravelerSignUpViewController else { return }
            travelerSignUpVC.travelerController = travelerController
            travelerSignUpVC.delegate = self
        }
    }
    
    func updateViews() {
        if let traveler = traveler {
            usernameTextField.text = traveler.username
            passwordTextField.text = traveler.password
        } else {
//            signInButton.isEnabled = false
//            signInButton.setTitleColor(.systemGray, for: .disabled)
        }
    }
}

extension TravelerSignInViewController: TravelerSignUpDelegate {
    func newTravelerCreated(_ traveler: TravelerRepresentation) {
        self.traveler = traveler
    }
    
    
}
