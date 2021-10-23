//
//  User.swift
//  Friends
//
//  Created by Andres Marquez on 2021-07-21.
//

import SwiftUI

struct User: Codable {
    var id: String
    var isActive: Bool
    var name: String
    var age: Int
    var company: String
    var email: String
    var address: String
    var about: String
    var tags: [String]
    var registered: String
    var friends: [Friend]
}


struct Friend: Codable {
    var id: String
    var name: String
}





