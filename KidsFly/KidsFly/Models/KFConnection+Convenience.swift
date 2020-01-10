//
//  KFConnection+Convenience.swift
//  KidsFly
//
//  Created by Craig Swanson on 12/19/19.
//  Copyright © 2019 Craig Swanson. All rights reserved.
//

import Foundation
import CoreData

extension KFConnection {
    
    // uncomment CodingKeys when we get the api endpoints.
    enum CodingKeys: String, CodingKey {
//        case identifier = ""
        case username = "username"
        case password = "password"
        case firstName = "first_name"
        case lastName = "last_name"
    }
    
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        username: String,
                                        password: String,
                                        firstName: String,
                                        lastName: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.identifier = identifier
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
    }
    
    @discardableResult convenience init?(kfConnectionRepresentation: KFConnectionRepresentation, context: NSManagedObjectContext) {
//        guard let identifierString = kfConnectionRepresentation.identifier,
//        let identifier =  UUID(uuidString: identifierString) else { return nil }
        
        self.init(username: kfConnectionRepresentation.username, password: kfConnectionRepresentation.password, firstName: kfConnectionRepresentation.first_name, lastName: kfConnectionRepresentation.last_name)
    }
    
    var kfConnectionRepresentation: KFConnectionRepresentation? {
        guard let username = username,
            let password = password,
            let firstName = firstName,
            let lastName = lastName else { return nil }
        return KFConnectionRepresentation(username: username, password: password, confirm: password, first_name: firstName, last_name: lastName)
    }
    
}
