//
//  Trip+Convenience.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/19/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import Foundation
import CoreData

extension Trip {
    
     // uncomment CodingKeys when we get the api endpoints.
    enum CodingKeys: String, CodingKey {
//        case identifier = ""
        case airport = "airport_name"
        case airline = "airline"
//        case completedStatus = ""
        case flightNumber = "flight_number"
        case departureTime = "departure_time"
        case childrenQty = "children"
        case carryOnQty = "carryon_items"
        case checkedBagQty = "checked_items"
        case notes = "special_needs"
    }
    
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        airport: String,
                                        airline: String,
                                        completedStatus: Bool = false,
                                        flightNumber: String,
                                        departureTime: Date,
                                        childrenQty: Int16,
                                        carryOnQty: Int16,
                                        checkedBagQty: Int16,
                                        notes: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.identifier = identifier
        self.airport = airport
        self.airline = airline
        self.completedStatus = completedStatus
        self.flightNumber = flightNumber
        self.departureTime = departureTime
        self.childrenQty = childrenQty
        self.carryOnQty = carryOnQty
        self.checkedBagQty = checkedBagQty
        self.notes = notes
    }
    
    @discardableResult convenience init?(tripRepresentation: TripRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let identifierString = tripRepresentation.identifier,
            let identifier = UUID(uuidString: identifierString),
            let airport = tripRepresentation.airport,
            let airline = tripRepresentation.airline,
            let completedStatus = tripRepresentation.completedStatus,
            let flightNumber = tripRepresentation.flightNumber,
            let departureTime = tripRepresentation.departureTime,
            let childrenQty = tripRepresentation.childrenQty,
            let carryOnQty = tripRepresentation.carryOnQty,
            let checkedBagQty = tripRepresentation.checkedBagQty,
            let notes = tripRepresentation.notes else { return nil }
        
        self.init(identifier: identifier, airport: airport, airline: airline, completedStatus: completedStatus, flightNumber: flightNumber, departureTime: departureTime, childrenQty: Int16(childrenQty), carryOnQty: Int16(carryOnQty), checkedBagQty: Int16(checkedBagQty), notes: notes)
    }
    
    var tripRepresentation: TripRepresentation {
        return TripRepresentation(identifier: identifier?.uuidString, airport: airport, airline: airline, completedStatus: completedStatus, flightNumber: flightNumber, departureTime: departureTime, childrenQty: Int(childrenQty), carryOnQty: Int(carryOnQty), checkedBagQty: Int(checkedBagQty), notes: notes)
    }
}
