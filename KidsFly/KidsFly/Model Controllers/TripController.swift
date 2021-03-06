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
    
//    var bearer: Bearer?
    private let baseURL = URL(string: "https://bw-kids-fly.herokuapp.com/api/")!
    var trips: [TripRepresentation] = []
    var openTrips: [TripRepresentation] = []  // Idea is to filter on completedStatus to find the Trip that has not been marked as completed.
    var completedTrips: [TripRepresentation] = []
    
//    init() {
//        fetchTripsFromServer()
//    }
    
    // MARK: - Put Trip to Server
    func put(traveler: Bearer, trip: Trip, method: HTTPMethod, completion: @escaping (Result<Bool, NetworkError>) -> Void = {_ in }) {
        
//        guard let bearer = traveler else {
//            print("Not authorized to put trip to server")
//            completion(.failure(.noAuthorization))
//            return
//        }

        let requestUrl = baseURL.appendingPathComponent("trips/trip")
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        request.setValue("\(traveler.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print(request)
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        do {
            let representation = trip.tripRepresentation
            guard let carryons = representation.carryOnQty,
                let checkedBags = representation.checkedBagQty,
                let children = representation.childrenQty else { return }
            let tripToPost = TripPostToServer(airport_name: representation.airport, airline: representation.airline, flight_number: representation.flightNumber, departure_time: representation.departureTime, carryon_items: String(carryons), checked_items: String(checkedBags), children: String(children), special_needs: representation.notes)
            
//            representation.identifier = identifier.uuidString
//            trip.identifier = identifier
            
            try CoreDataStack.shared.save()
            request.httpBody = try jsonEncoder.encode(tripToPost)
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
        
        // The following block is me trying to understand how the relationships work between the two models.
        //        let traveler = Traveler(identifier: UUID(), username: "bob", password: "jones", firstName: "bob", lastName: "jones", streetAddress: "123", cityAddress: "madris", stateAddress: "MN", zipCode: "55352", phoneNumber: "34543", airport: "MSP", context: CoreDataStack.shared.mainContext)
        //        let trip1 = Trip(identifier: UUID(), airport: "MSP", airline: "Delta", flightNumber: "345", departureTime: Date(), childrenQty: 2, carryOnQty: 2, checkedBagQty: 2, notes: "None", context: CoreDataStack.shared.mainContext)
        //        traveler.trips = [trip1]
        //
    }
    
    // MARK: - Fetch Trips from Server
    func fetchTripsFromServer(traveler: Bearer, completion: @escaping (Result<[TripRepresentation], NetworkError>) -> Void = {_ in }) {
     
/* TESTING WITH FIREBASE URL -- UNCOMMENT THIS FOR PRODUCTION BACK END */
//        guard let travelerController = travelerController,
//            let bearer = travelerController.bearer else {
//            completion(.failure(.noAuthorization))
//            return
//        }
        
        let requestUrl = baseURL.appendingPathComponent("trips")
        var request = URLRequest(url: requestUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("\(traveler.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 201 {
                completion(.failure(.otherError))
                return
            }

/*  THIS BLOCK WAS USED TO TEST WITH FIREBASE BEFORE OUR BACKEND WAS WORKING
        let requestUrl = baseURL.appendingPathExtension("json")
        let request = URLRequest(url: requestUrl)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if error != nil {
                completion(.failure(.otherError))
                return
            }
*/
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
    
    func updateExistingTrip(for traveler: Bearer, trip: Trip) {
        put(traveler: traveler, trip: trip, method: HTTPMethod.put)
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
