//
//  JSONView.swift
//  Friends
//
//  Created by Andres Marquez on 2021-07-28.
//

import SwiftUI
import CoreData

class JSONViewModel: ObservableObject {
    
    @Published var users : [User] = []
    
    //Save JSON into Coredata
    func saveData(context: NSManagedObjectContext){
        users.forEach {(data) in
            let entity = UserData(context: context)
            entity.name = data.name
            entity.id = data.id
            entity.isActive = data.isActive
            entity.company = data.company
            entity.age = Int16(data.age)
            entity.email = data.email
            entity.about = data.about
            entity.address = data.address
            for tag in data.tags {
                entity.tags.append(tag)
            }
            
           var tempFriends = [UserFriend]()
            
            for friend in data.friends {
                let addFriend = UserFriend(context: context)
                addFriend.name = friend.name
                addFriend.id = friend.id
                tempFriends.append(addFriend)
            }
            
            entity.friends = NSSet(array: tempFriends)
            
            do {

                try context.save()
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    //Parse JSON into users variable
    func loadData(context: NSManagedObjectContext) {
        guard let url = URL(string: "https://www.hackingwithswift.com/samples/friendface.json") else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([User].self, from: data) {
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        // update our UI
                        self.users = decodedResponse
                        
                        //save
                        self.saveData(context: context)
                    }

                    // everything is good, so we can exit
                    return
                }
            }

            // if we're still here it means there was a problem
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    //Delete and load once more
    func reload(context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")

        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)

        } catch {
            print("Error deleting")
        }
        
        self.loadData(context: context)
    }
}
