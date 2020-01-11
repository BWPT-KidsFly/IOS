//
//  TravelerController.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/19/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class TravelerController {
    
    // If there is an active (non-completed) trip, that should be highlighted
    
    var traveler: TravelerRepresentation?
    var bearer: Bearer?
    private let baseURL = URL(string: "https://bw-kids-fly.herokuapp.com/api/")!

    // MARK: - Sign Up New Traveler
    
    /* Example Output:
    { "id": 1, "username": "LambdaStudent247", "password": "$2a$10$6NrOGH/43.iC.t8gndaGV.N3ZNRnaaoln44K.urxOCsgmdwp67EeK", "first_name": "Heather", "last_name": "Ridgill", "street_address": "123 Lambda Court", "city": "LambdaVille", "state": "CA", "zip": "92831", "phone_number": "555-555-5555", "home_airport": "LAX", "admin": 0 }
    */
    
    func signUp(with traveler: TravelerRepresentation, completion: @escaping (Error?) -> ()) {
        let signUpURL = baseURL.appendingPathComponent("auth/register/user")
        
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(traveler)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
            response.statusCode != 201 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
  // THIS WAS USED FOR TESTING TO UNDERSTAND WHY I COULDN'T GET A VALID SIGN UP.
//            guard let data = data else {
//                print("Error in data")
//                return
//            }
//          let decoder = JSONDecoder()
//            do {
//                print(traveler)
//                try decoder.decode(TravelerRepresentation.self, from: data)
//            } catch {
//                print("Error decoding sign up data: \(error)")
//                completion(error)
//                return
//            }
            completion(nil)
        }.resume()
    }
    
    // MARK: - Log In Traveler
    func logIn(with traveler: TravelerLogIn, completion: @escaping (Error?) -> ()) {
        let logInUrl = baseURL.appendingPathComponent("auth/login/user")
        
        var request = URLRequest(url: logInUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(traveler)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                print("Error retrieving bearer data at log in")
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
            } catch {
                print("Error decoding bearer object: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
}
