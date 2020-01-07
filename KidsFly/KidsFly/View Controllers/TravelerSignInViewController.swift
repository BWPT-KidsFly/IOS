//
//  TravelerSignInViewController.swift
//  KidsFly
//
//  Created by Craig Swanson on 1/6/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import UIKit


// TODO: Add this to the main.storyboard as well as the segue. Delete the existing segue from tableview to signUp.  Add segue from here to signUp.

//  This idea behind this view is that is accessed when launching the app and provides the user a username and password field to login. There is also a new user registration button to tap if the user does not yet have proper credentials.

class TravelerSignInViewController: UIViewController {
    
    var travelerController: TravelerController?
    var traveler: TravelerRepresentation? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViews()
    }
    
    @IBAction func userRegistrationButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "UserRegistrationSegue", sender: self)
    }
    
    @IBAction func userSignIn(_ sender: UIButton) {
        guard let travelerController = travelerController,
            let traveler = traveler else { return }
        if let username = usernameTextField.text,
            !username.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty {
/* COMMENTING THIS OUT UNTIL OUR BACKEND AUTHORIZATION IS FUNCTIONAL
            travelerController.logIn(with: traveler) { error in
                if let error = error {
                    print("Error occurred during logging in: \(error)")
                } else {
 
                    // Until we get the backend up and running I am going to manually set a bearer token value and dismiss the view controller screen.
                    travelerController.bearer?.token = "yes"
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
*/
            // Until we get the backend up and running I am going to manually set a bearer token value and dismiss the view controller screen.
            travelerController.bearer?.token = "yes"
                self.dismiss(animated: true, completion: nil)
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
