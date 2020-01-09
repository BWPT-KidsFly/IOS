//
//  TravelerSignInViewController.swift
//  KidsFly
//
//  Created by Craig Swanson on 1/6/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import UIKit

//  This idea behind this view is that is accessed when launching the app and provides the user a username and password field to login. There is also a new user registration button to tap if the user does not yet have proper credentials.

// Change state based on segmented control state -- either a traveler or a KC Agent
enum UserType {
    case traveler
    case kidsConnectionAgent
}

class TravelerSignInViewController: UIViewController {
    
    var travelerController: TravelerController?
    var tripController: TripController?
    var kfConnectionController: KFConnectionController?
    var userType = UserType.traveler
    var traveler: TravelerRepresentation? {
        didSet {
            updateViews()
        }
    }
    var kfConnection: KFConnectionRepresentation? {
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
        if sender.selectedSegmentIndex == 0 {
            userType = .traveler
            newUserLabel.text = "New User?"
        } else {
            userType = .kidsConnectionAgent
            newUserLabel.text = "New KidConnection Agent?"
        }
    }
    
    @IBAction func userRegistrationButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "UserRegistrationSegue", sender: self)
    }
    
    @IBAction func userSignIn(_ sender: UIButton) {
        guard let travelerController = travelerController,
            let kfconnectionController = kfConnectionController else { return }
        //            let traveler = traveler else { return }
        if let username = usernameTextField.text,
            !username.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty {
            
            switch userType {
            case .traveler:
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
            case .kidsConnectionAgent:
                guard let kfConnection = kfConnection else { return }
                kfconnectionController.logIn(with: kfConnection) { error in
                    if let error = error {
                        print("Error occured during loggin in KFC: \(error)")
                    } else {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
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
            travelerSignUpVC.kfConnectionController = kfConnectionController
            travelerSignUpVC.delegate = self
            travelerSignUpVC.userType = userType
        }
    }
    
    func updateViews() {
        
        switch userType {
        case .traveler:
            if let traveler = traveler {
                usernameTextField.text = traveler.username
                passwordTextField.text = traveler.password
            } else {
                //            signInButton.isEnabled = false
                //            signInButton.setTitleColor(.systemGray, for: .disabled)
            }
        case .kidsConnectionAgent:
            if let kfConnection = kfConnection {
                usernameTextField.text = kfConnection.username
                passwordTextField.text = kfConnection.password
            }
        }
    }
}

extension TravelerSignInViewController: TravelerSignUpDelegate {
    func newKFConnectionCreated(_ kfConnection: KFConnectionRepresentation) {
        self.kfConnection = kfConnection
    }
    
    func newTravelerCreated(_ traveler: TravelerRepresentation) {
        self.traveler = traveler
    }
    
}
