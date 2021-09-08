//
//  RollView.swift
//  DiceRoller
//
//  Created by Andres Marquez on 2021-09-06.
//

import SwiftUI

struct RollView: View {
    //@State private var amountOfDices = 1
    
    @Environment(\.managedObjectContext) var moc
    @State private var numberRolled = 1
    
    var body: some View {
        NavigationView {
            VStack {
                /*
                Stepper(value: $amountOfDices, in: 1 ... 5 , step: 1) {
                    Text("Number of Dices: \(amountOfDices)")
                        .font(.title2)
                }
 */
                
                Text("\(numberRolled)")
                    .font(.system(size: 150))
                    .frame(width: 200, height: 200, alignment: .center)
                    .border(Color.black, width: 7)
                    .padding()
                
                Button(action: {
                    self.numberRolled = Int.random(in: 1...6)
                    self.saveRoll(numberRolled: Int16(numberRolled))
                }, label: {
                    Text("Roll")
                        .font(.title)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                })
            }
            .navigationBarTitle("Roll Dice")
        }
    }
    
    func saveRoll(numberRolled: Int16) {
        let newRoll = HistoricalRolls(context: moc)
        newRoll.roll = numberRolled
        newRoll.date = Date()
        PersistenceController.shared.save()
    }
}

struct RollView_Previews: PreviewProvider {
    static var previews: some View {
        RollView()
    }
}
