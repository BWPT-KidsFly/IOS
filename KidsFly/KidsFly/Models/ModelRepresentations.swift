//
//  ModelRepresentations.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/19/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import Foundation

struct TravelerRepresentation: Equatable, Codable {
    var identifier: String?
    var username: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    var streetAddress: String?
    var cityAddress: String?
    var stateAddress: String?
    var zipCode: String?
    var phoneNumber: String?
    var airport: String?
}

struct KFConnectionRepresentation: Equatable, Codable {
    var identifier: String?
    var username: String?
    var password: String?
}

struct TripRepresentation: Equatable, Codable {
    var identifier: String?
    var airport: String?
    var airline: String?
    var flightNumber: String?
    var departureTime: Date?
    var childrenQty: Int?
    var carryOnQty: Int?
    var checkedBagQty: Int?
    var notes: String?
}
