//
//  ModelRepresentations.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/19/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import Foundation

struct TravelerRepresentation: Equatable, Codable {
//    var identifier: String?
    var username: String
    var password: String
    var confirm: String
    var first_name: String?
    var last_name: String?
    var street_address: String?
    var city: String?
    var state: String?
    var zip: String?
    var phone_number: String?
    var home_airport: String?
}

struct TravelerLogIn: Equatable, Codable {
    var username: String
    var password: String
}

struct KFConnectionRepresentation: Equatable, Codable {
//    var identifier: String?
    var username: String
    var password: String
    var confirm: String
    var first_name: String
    var last_name: String
}

struct TripRepresentation: Equatable, Codable {
    var identifier: String?
    var airport: String?
    var airline: String?
    var completedStatus: Bool?
    var flightNumber: String?
    var departureTime: Date?
    var childrenQty: Int?
    var carryOnQty: Int?
    var checkedBagQty: Int?
    var notes: String?
}
