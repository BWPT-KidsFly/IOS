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
    
    @discardableResult convenience init(identifier: UUID,
                                        airport: String,
                                        airline: String,
                                        flightNumber: String,
                                        departureTime: Date,
                                        childrenQty: Int,
                                        carryOnQty: Int,
                                        checkedBagQty: Int,
                                        notes: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.identifier = identifier
        self.airport = airport
        self.airline = airline
        self.flightNumber = flightNumber
        self.departureTime = departureTime
        self.childrenQty = Int16(childrenQty)
        self.carryOnQty = Int16(carryOnQty)
        self.checkedBagQty = Int16(checkedBagQty)
        self.notes = notes
    }
    
    @discardableResult convenience init?(tripRepresentation: TripRepresentation, context: NSManagedObjectContext) {
        
        guard let identifier = tripRepresentation.identifier,
            let airport = tripRepresentation.airport,
            let airline = tripRepresentation.airline,
            let flightNumber = tripRepresentation.flightNumber,
            let departureTime = tripRepresentation.departureTime,
            let childrenQty = tripRepresentation.childrenQty,
            let carryOnQty = tripRepresentation.carryOnQty,
            let checkedBagQty = tripRepresentation.checkedBagQty,
            let notes = tripRepresentation.notes else { return nil }
        
        self.init(identifier: UUID(uuidString: identifier) ?? UUID(), airport: airport, airline: airline, flightNumber: flightNumber, departureTime: departureTime, childrenQty: childrenQty, carryOnQty: carryOnQty, checkedBagQty: checkedBagQty, notes: notes)
    }
    
    var tripRepresentation: TripRepresentation {
        return TripRepresentation(identifier: identifier?.uuidString, airport: airport, airline: airline, flightNumber: flightNumber, departureTime: departureTime, childrenQty: Int(childrenQty), carryOnQty: Int(carryOnQty), checkedBagQty: Int(checkedBagQty), notes: notes)
    }
}
