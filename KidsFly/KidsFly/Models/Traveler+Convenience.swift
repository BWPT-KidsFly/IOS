//
//  Traveler+Convenience.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/19/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import Foundation
import CoreData

extension Traveler {
    
    // uncomment CodingKeys when we get the api endpoints.
    enum CodingKeys: String, CodingKey {
//        case identifier = ""
        case username = "username"
        case password = "password"
        case firstName = "first_name"
        case lastName = "last_name"
        case streetAddress = "street_address"
        case cityAddress = "city"
        case stateAddress = "state"
        case zipCode = "zip"
        case phoneNumber = "phone_number"
        case airport = "home_airport"
    }
    
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        username: String,
                                        password: String,
                                        firstName: String,
                                        lastName: String,
                                        streetAddress: String,
                                        cityAddress: String,
                                        stateAddress: String,
                                        zipCode: String,
                                        phoneNumber: String,
                                        airport: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.identifier = identifier
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.streetAddress = streetAddress
        self.cityAddress = cityAddress
        self.stateAddress = stateAddress
        self.zipCode = zipCode
        self.phoneNumber = phoneNumber
        self.airport = airport
    }
    
    @discardableResult convenience init?(travelerRepresentation: TravelerRepresentation, context: NSManagedObjectContext) {
        
//        guard let identifierString = travelerRepresentation.identifier,
//            let identifier = UUID(uuidString: identifierString),
            guard let firstName = travelerRepresentation.first_name,
            let lastName = travelerRepresentation.last_name,
            let streetAddress = travelerRepresentation.street_address,
            let cityAddress = travelerRepresentation.city,
            let stateAddress = travelerRepresentation.state,
            let zipCode = travelerRepresentation.zip,
            let phoneNumber = travelerRepresentation.phone_number,
            let airport = travelerRepresentation.home_airport else { return nil }
        
        self.init(username: travelerRepresentation.username, password: travelerRepresentation.password, firstName: firstName, lastName: lastName, streetAddress: streetAddress, cityAddress: cityAddress, stateAddress: stateAddress, zipCode: zipCode, phoneNumber: phoneNumber, airport: airport)
    }
    
    var travelerRepresentation: TravelerRepresentation? {
        guard let username = username,
            let password = password else { return nil }
        return TravelerRepresentation(username: username, password: password, confirm: password, first_name: firstName, last_name: lastName, street_address: streetAddress, city: cityAddress, state: stateAddress, zip: zipCode, phone_number: phoneNumber, home_airport: airport)
    }
}
