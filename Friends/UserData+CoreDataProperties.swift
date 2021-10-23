//
//  UserData+CoreDataProperties.swift
//  Friends
//
//  Created by Andres Marquez on 2021-07-30.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var about: String?
    @NSManaged public var address: String?
    @NSManaged public var age: Int16
    @NSManaged public var company: String?
    @NSManaged public var email: String?
    @NSManaged public var id: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var name: String?
    @NSManaged public var registered: String?
    @NSManaged public var tags: [String]
    @NSManaged public var friends: NSSet?
    
    var wrappedId: String {
        return id ?? ""
    }

    var wrappedName: String {
        return name ?? ""
    }
        
    var friendsArray: [UserFriend] {
        let set = friends as? Set<UserFriend> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }

}

extension UserData : Identifiable {

}
