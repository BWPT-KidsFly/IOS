//
//  TripController.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/27/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class TripController {
    
    var travelerController: TravelerController?
    
    private let baseURL = URL(string: "https://kidsfly-43b49.firebaseio.com/")! // TODO: Change url
    var trips: [TripRepresentation] = []
    var openTrips: [TripRepresentation] = []  // Idea is to filter on completedStatus to find the Trip that has not been marked as completed.
    var completedTrips: [TripRepresentation] = []
    
    init() {
        fetchTripsFromServer()
    }
    
    // MARK: - Put Trip to Server
    func put(traveler: TravelerRepresentation, trip: Trip, completion: @escaping (Result<Bool, NetworkError>) -> Void = {_ in }) {
        
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
        let requestUrl = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        do {
            var representation = trip.tripRepresentation
            representation.identifier = identifier.uuidString
            trip.identifier = identifier
            try CoreDataStack.shared.save()
            request.httpBody = try jsonEncoder.encode(representation)
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
            completion(.success(true))
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
    func fetchTripsFromServer(completion: @escaping (Result<[TripRepresentation], NetworkError>) -> Void = {_ in }) {
     
/* TESTING WITH FIREBASE URL -- UNCOMMENT THIS FOR PRODUCTION BACK END
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
*/
        
        let requestUrl = baseURL.appendingPathExtension("json")
        let request = URLRequest(url: requestUrl)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
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
                self.trips = Array(try decoder.decode([String : TripRepresentation].self, from: data).values)
                
                self.openTrips = self.trips.filter {$0.completedStatus == false}
                self.completedTrips = self.trips.filter {$0.completedStatus == true}
                
                // At this point the trips are in the correct arrays corresponding to the server data. They lose their organization subsquently in core data. I assume this is because I am not yet calling the updateTrips method.
                
                try self.updateTrips(with: self.trips)
                completion(.success(self.trips))
            } catch {
                print("Error decoding all Trips: \(error)")
                completion(.failure(.notDecodedProperly))
                return
            }
        }.resume()
    }
    
    // MARK: - Update Core Data
    func updateTrips(with representations: [TripRepresentation]) throws {
        let tripsWithID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = tripsWithID.compactMap { $0.identifier }
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, tripsWithID))
        
        var tripsToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        let moc = CoreDataStack.shared.container.newBackgroundContext()
        
        moc.perform {
            do {
                let existingTrips = try moc.fetch(fetchRequest)
                
                for trip in existingTrips {
                    guard let id = trip.identifier?.uuidString,
                        let representation = representationsByID[id] else {
//                            let moc = CoreDataStack.shared.mainContext
                            moc.delete(trip)
                            continue
                    }
                    
                    self.update(trip: trip, representation: representation)
                    
                    tripsToCreate.removeValue(forKey: id)
                }
                
                for representation in tripsToCreate.values {
                    Trip(tripRepresentation: representation, context: moc)
                }
            } catch {
                print("Error fetching trips for identifiers: \(error)")
            }
        }
        try CoreDataStack.shared.save(context: moc)
    }
    
    // MARK: - Helpers
    func update(trip: Trip, representation: TripRepresentation) {
        trip.airline = representation.airline
        trip.airport = representation.airport
        trip.carryOnQty = Int16(representation.carryOnQty!)
        trip.checkedBagQty = Int16(representation.checkedBagQty!)
        trip.childrenQty = Int16(representation.childrenQty!)
        trip.completedStatus = representation.completedStatus!
        trip.departureTime = representation.departureTime
        trip.flightNumber = representation.flightNumber
        trip.identifier = UUID(uuidString: representation.identifier!)
        trip.notes = representation.notes
    }
    
    func deleteTrip(for trip: Trip) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(trip)
        deleteTripFromServer(trip)
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error deleting trip from Core Data")
        }
    }
    
    func updateExistingTrip(for traveler: TravelerRepresentation, trip: Trip) {
        put(traveler: traveler, trip: trip)
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error updating existing trip")
        }
    }
    
    func deleteTripFromServer(_ trip: Trip, completion: @escaping (Error?) -> Void = {_ in }) {
        guard let identifier = trip.identifier else {
            completion(NSError())
            return
        }
        
        let requestUrl = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            guard error == nil else {
                print("Error deleting trip from server: \(error!)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
}
