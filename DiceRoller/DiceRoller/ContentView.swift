//
//  ContentView.swift
//  DiceRoller
//
//  Created by Andres Marquez on 2021-09-06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RollView()
                .tabItem {
                    Image(systemName: "play.fill")
                }
            
            PreviousRollView()
                .tabItem {
                    Image(systemName: "clock.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
