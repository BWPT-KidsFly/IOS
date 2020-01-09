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
    }
    
    @discardableResult convenience init(identifier: UUID,
                                        username: String,
                                        password: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.identifier = identifier
        self.username = username
        self.password = password
    }
    
    @discardableResult convenience init?(kfConnectionRepresentation: KFConnectionRepresentation, context: NSManagedObjectContext) {
        guard let identifierString = kfConnectionRepresentation.identifier,
        let identifier =  UUID(uuidString: identifierString) else { return nil }
        
        self.init(identifier: identifier, username: kfConnectionRepresentation.username, password: kfConnectionRepresentation.password)
    }
    
    var kfConnectionRepresentation: KFConnectionRepresentation? {
        guard let username = username,
            let password = password else { return nil }
        return KFConnectionRepresentation(identifier: identifier?.uuidString, username: username, password: password)
    }
    
}
