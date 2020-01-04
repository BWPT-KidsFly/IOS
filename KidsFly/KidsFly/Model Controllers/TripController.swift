//
//  TripController.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/27/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import Foundation
import UIKit

class TripController {
    
    var travelerController: TravelerController?
    
    private let baseURL = URL(string: "https://kidsfly-43b49.firebaseio.com/")! // TODO: Change url
    var trips: [TripRepresentation] = []
    var openTrips: [TripRepresentation] = []  // Idea is to filter on completedStatus to find the Trip that has not been marked as completed.
    var completedTrips: [TripRepresentation] = []
    
    // MARK: - Put Trip to Server
    func put(traveler: TravelerRepresentation, trip: TripRepresentation, completion: @escaping (Result<Bool, NetworkError>) -> Void = {_ in }) {
        
/* TESTING WITH FIREBASE URL -- UNCOMMENT THIS FOR PRODUCTION BACK END
//        guard let travelerController = travelerController,
//            let bearer = travelerController.bearer else {
//            print("No authorized to put trip to server")
//            completion(.failure(.noAuthorization))
//            return
//        }
//
//        let requestUrl = baseURL.appendingPathComponent("trips") // TODO: change URL
//        var request = URLRequest(url: requestUrl)
//        request.httpMethod = HTTPMethod.post.rawValue  // TODO: post or put?
//        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
 */
        guard let identifier = trip.identifier else { return }
        let requestUrl = baseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        
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
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil else {
                print("Error PUTing task to server: \(error!)")
                completion(.failure(.otherError))
                return
            }
          
        }.resume()
        
/* TESTING WITH FIREBASE URL -- UNCOMMENT THIS FOR PRODUCTION BACK END
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
                // I'm not sure what the API will return -- either all trips or a single trip?  This assumes only the new trip and then appends it to the array with this data.
                let newTrip = try decoder.decode(TripRepresentation.self, from: data)
                self.trips.append(newTrip)
                self.openTrips = self.trips.filter {$0.completedStatus == false}
                self.completedTrips = self.trips.filter {$0.completedStatus == true}
                completion(.success(true))
            } catch {
                print("Error decoding new Trip: \(error)")
                completion(.failure(.notDecodedProperly))
                return
            }
        }.resume()
 */
        // The following block is me trying to understand how the relationships work between the two models.
        //        let traveler = Traveler(identifier: UUID(), username: "bob", password: "jones", firstName: "bob", lastName: "jones", streetAddress: "123", cityAddress: "madris", stateAddress: "MN", zipCode: "55352", phoneNumber: "34543", airport: "MSP", context: CoreDataStack.shared.mainContext)
        //        let trip1 = Trip(identifier: UUID(), airport: "MSP", airline: "Delta", flightNumber: "345", departureTime: Date(), childrenQty: 2, carryOnQty: 2, checkedBagQty: 2, notes: "None", context: CoreDataStack.shared.mainContext)
        //        traveler.trips = [trip1]
        //
    }
    
    // MARK: - Fetch Trips from Server
    func fetchTripsFromServer(traveler: TravelerRepresentation, completion: @escaping (Result<[TripRepresentation], NetworkError>) -> Void = {_ in }) {
        guard let travelerController = travelerController,
            let bearer = travelerController.bearer else {
            completion(.failure(.noAuthorization))
            return
        }
        
        let requestUrl = baseURL.appendingPathComponent("trips") // TODO: change URL
        var request = URLRequest(url: requestUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
                self.trips = []
                self.openTrips = []
                self.completedTrips = []
                let allTrips = try decoder.decode([TripRepresentation].self, from: data)
                self.trips = allTrips
                self.openTrips = self.trips.filter {$0.completedStatus == false}
                self.completedTrips = self.trips.filter {$0.completedStatus == true}
                completion(.success(allTrips))
            } catch {
                print("Error decoding all Trips: \(error)")
                completion(.failure(.notDecodedProperly))
                return
            }
        }.resume()
    }
}
