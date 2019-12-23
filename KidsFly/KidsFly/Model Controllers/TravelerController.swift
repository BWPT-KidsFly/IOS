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
}

class TravelerController {
    
    // Return the traveler's data and also their associated trips.
    // If there is an active (non-completed) trip, that should be highlighted
    
    
    var bearer: Bearer?
    private let baseURL = URL(string: "lambdaanimalspotter.vapor.cloud/api")! // TODO: Change url
    var trips: [TripRepresentation] = []
    
    
    // MARK: - Sign Up New Traveler
    func signUp(with traveler: TravelerRepresentation, completion: @escaping (Error?) -> ()) {
        let signUpURL = baseURL.appendingPathComponent("auth/register")
        
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
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    // MARK: - Log In Traveler
    func logIn(with traveler: TravelerRepresentation, completion: @escaping (Error?) -> ()) {
        let logInUrl = baseURL.appendingPathComponent("auth/login")
        
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
    
    // MARK: - Put Trip to Server
    func put(traveler: TravelerRepresentation, trip: TripRepresentation, completion: @escaping (Result<Bool, NetworkError>) -> Void = {_ in }) {
        guard let bearer = bearer else {
            print("No authorized to put trip to server")
            completion(.failure(.noAuthorization))
            return
        }
        
        let requestUrl = baseURL.appendingPathComponent("trips") // TODO: change URL
        var request = URLRequest(url: requestUrl)
        request.httpMethod = HTTPMethod.post.rawValue  // TODO: post or put?
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        do {
            let jsonData = try jsonEncoder.encode(trip)
            request.httpBody = jsonData
        } catch {
            print("Error encoding trip: \(error)")
            completion(.failure(.notEncodedProperly))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.otherError))
                return
            }
            
            if error != nil {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let allTrips = try decoder.decode(TripRepresentation.self, from: data)
                self.trips.append(allTrips)
                completion(.success(true))
            } catch {
                print("Error decoding new Trip: \(error)")
                completion(.failure(.notDecodedProperly))
                return
            }
        }.resume()
        // The following block is me trying to understand how the relationships work between the two models.
//        let traveler = Traveler(identifier: UUID(), username: "bob", password: "jones", firstName: "bob", lastName: "jones", streetAddress: "123", cityAddress: "madris", stateAddress: "MN", zipCode: "55352", phoneNumber: "34543", airport: "MSP", context: CoreDataStack.shared.mainContext)
//        let trip1 = Trip(identifier: UUID(), airport: "MSP", airline: "Delta", flightNumber: "345", departureTime: Date(), childrenQty: 2, carryOnQty: 2, checkedBagQty: 2, notes: "None", context: CoreDataStack.shared.mainContext)
//        traveler.trips = [trip1]
//
    }
}
