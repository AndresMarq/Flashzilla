//
//  UserView.swift
//  Friends
//
//  Created by Andres Marquez on 2021-07-21.
//

import SwiftUI
import CoreData

struct UserView: View {
    @State var user: UserData
    
    //@StateObject var jsonModel = JSONViewModel()
    //@Environment(\.managedObjectContext) var moc
    
    //
    @FetchRequest(entity: UserData.entity(), sortDescriptors: []) var results: FetchedResults<UserData>
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Age:")
                        .bold()
                    Text("\(self.user.age)")
                } .padding(.bottom)
                
                HStack {
                    Text("Company:")
                        .bold()
                    Text("\(self.user.company ?? "Unknown")")
                } .padding(.bottom)
                
                HStack {
                    Text("email:")
                        .bold()
                    Text("\(self.user.email ?? "Unknown")")
                } .padding(.bottom)
                
                HStack {
                    Text("Address:")
                        .bold()
                    Text("\(self.user.address ?? "Unknown")")
                } .padding(.bottom)
                
                Text("Tags:")
                    .bold()
                
                ForEach(self.user.tags, id: \.self) {
                    Text("#\($0).")
                }
                
                Text("About me:")
                    .bold()
                    .padding(.top)
                
                Text(self.user.about ?? "")
                    .padding([.horizontal, .bottom])
                
                VStack(alignment: .leading) {
                    Text("Friends in common:")
                        .bold()
                    
                    ForEach(self.user.friendsArray, id: \.id) { friend in
                        Button(action: {
                            for _ in results {
                                if let match = results.first(where: { $0.id == friend.id }) {
                                    user = match
                                } else {
                                    fatalError("Friend found not to be among user list")
                                }
                            }
                        }, label: {
                            Text(friend.name ?? "Unknown friend")
                        })
                    }
                }
            }
            .navigationBarTitle(self.user.name ?? "No Name")
        }
    }
    
    //init(user: UserData) {
      //  self.user = user
    //}
}

