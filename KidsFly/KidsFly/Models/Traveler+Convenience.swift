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
        
        guard let identifierString = travelerRepresentation.identifier,
            let identifier = UUID(uuidString: identifierString),
            let firstName = travelerRepresentation.firstName,
            let lastName = travelerRepresentation.lastName,
            let streetAddress = travelerRepresentation.streetAddress,
            let cityAddress = travelerRepresentation.cityAddress,
            let stateAddress = travelerRepresentation.stateAddress,
            let zipCode = travelerRepresentation.zipCode,
            let phoneNumber = travelerRepresentation.phoneNumber,
            let airport = travelerRepresentation.airport else { return nil }
        
        self.init(identifier: identifier, username: travelerRepresentation.username, password: travelerRepresentation.password, firstName: firstName, lastName: lastName, streetAddress: streetAddress, cityAddress: cityAddress, stateAddress: stateAddress, zipCode: zipCode, phoneNumber: phoneNumber, airport: airport)
    }
    
    var travelerRepresentation: TravelerRepresentation? {
        guard let username = username,
            let password = password else { return nil }
        return TravelerRepresentation(identifier: identifier?.uuidString, username: username, password: password, firstName: firstName, lastName: lastName, streetAddress: streetAddress, cityAddress: cityAddress, stateAddress: stateAddress, zipCode: zipCode, phoneNumber: phoneNumber, airport: airport)
    }
}
