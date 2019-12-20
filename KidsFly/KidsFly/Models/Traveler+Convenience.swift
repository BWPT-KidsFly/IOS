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
//    enum CodingKeys: String, CodingKey {
//        case identifier = ""
//        case username = ""
//        case password = ""
//        case firstName = ""
//        case lastName = ""
//        case streetAddress = ""
//        case cityAddress = ""
//        case stateAddress = ""
//        case zipCode = ""
//        case phoneNumber = ""
//        case airport = ""
//    }
    
    var travelerRepresentation: TravelerRepresentation? {
        guard let username = username,
            let password = password else { return nil }
        return TravelerRepresentation(identifier: identifier?.uuidString ?? UUID().uuidString, username: username, password: password, firstName: firstName, lastName: lastName, streetAddress: streetAddress, cityAddress: cityAddress, stateAddress: stateAddress, zipCode: zipCode, phoneNumber: phoneNumber, airport: airport)
    }
}
