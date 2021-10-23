//
//  UserFriend+CoreDataProperties.swift
//  Friends
//
//  Created by Andres Marquez on 2021-08-02.
//
//

import Foundation
import CoreData


extension UserFriend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserFriend> {
        return NSFetchRequest<UserFriend>(entityName: "UserFriend")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: String?
    
    var wrappedId: String {
        return id ?? ""
    }

    var wrappedName: String {
        return name ?? ""
    }

}

extension UserFriend : Identifiable {

}
