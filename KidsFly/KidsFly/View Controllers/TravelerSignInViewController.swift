//
//  TravelerSignInViewController.swift
//  KidsFly
//
//  Created by Craig Swanson on 1/6/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import UIKit

class TravelerSignInViewController: UIViewController {
    
    var travelerController: TravelerController?
    var traveler: TravelerRepresentation?

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserRegistrationSegue" {
            guard let travelerSignUpVC = segue.destination as? TravelerSignUpViewController else { return }
            travelerSignUpVC.travelerController = travelerController
        }
    }

}
