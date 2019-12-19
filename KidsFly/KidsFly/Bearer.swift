//
//  Bearer.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/19/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import Foundation

// used to get the authorization token from the API
struct Bearer: Codable {
    let token: String
}
