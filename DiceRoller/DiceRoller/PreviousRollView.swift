//
//  PreviousRollView.swift
//  DiceRoller
//
//  Created by Andres Marquez on 2021-09-06.
//

import SwiftUI

struct PreviousRollView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: HistoricalRolls.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HistoricalRolls.date, ascending: false)]) var rolls: FetchedResults<HistoricalRolls>
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(rolls, id: \.self) { roll in
                    HStack {
                        Text("\(roll.roll)")
                            .frame(width: 30, height: 30, alignment: .center)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        Text(" \(roll.date ?? Date(), formatter: dateFormatter)")
                    }
                }
                .onDelete(perform: removeRoll)
            }
            .navigationBarTitle("Previous Rolls")
        }
    }
    
    func removeRoll(at offsets: IndexSet) {
        for index in offsets {
            let roll = rolls[index]
            PersistenceController.shared.delete(roll)
        }
    }
}

struct PreviousRollView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousRollView()
    }
}
    
