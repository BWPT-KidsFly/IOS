//
//  Error Codes.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/23/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case noAuthorization
    case incorrectAuthorization
    case badData
    case notDecodedProperly
    case notEncodedProperly
    case otherError
}
