//
//  FriendsApp.swift
//  Friends
//
//  Created by Andres Marquez on 2021-07-21.
//

import SwiftUI

@main
struct FriendsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
