//
//  ContentView.swift
//  Flashzilla
//
//  Created by Andres Marquez on 2021-08-22.
//

import SwiftUI
import CoreHaptics

struct ContentView: View {
    @State private var cards = [Card]()
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    @State private var isActive = true
    @State private var showingEditScreen = false
    @State private var showTimeOutAlert = false
    @State private var showSettingScreen = false
    @State private var recycleWrongAnswers = false
    
    @State private var engine: CHHapticEngine?

        var body: some View {
            ZStack {
                Image(decorative: "background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                    
                
                VStack {
                    HStack {
                        Button(action: {
                            self.showSettingScreen = true
                        }, label: {
                            Image(systemName: "gearshape")
                                .renderingMode(.original)
                                .font(.title)
                        })
                    
                        Text("Time: \(timeRemaining)")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                    }
                    
                    ZStack {
                        ForEach(0..<cards.count, id: \.self) { index in
                            //If recycle card setting selected, wrong answers go back to the stack
                            let removal = { (rightAnswer: Bool) in
                                if rightAnswer == false && self.recycleWrongAnswers == true {
                                    let wrongAnswer = self.cards.remove(at: index)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.cards.insert(wrongAnswer, at: 0)
                                    }
                                } else {
                                    withAnimation {
                                        self.removeCard(at: index)
                                    }
                                }
                            }
                            CardView(card: self.cards[index], removal: removal)
                                .stacked(at: index, in: self.cards.count)
                                .allowsHitTesting(index == self.cards.count - 1)
                                .accessibility(hidden: index < self.cards.count - 1)
                        }
                        .allowsTightening(timeRemaining > 0)
                        
                        if cards.isEmpty {
                            Button("Start Again", action: resetCards)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                VStack {
                    HStack {
                        Spacer()

                        Button(action: {
                            self.showingEditScreen = true
                        }) {
                            Image(systemName: "plus.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }

                    Spacer()
                }
                .foregroundColor(.white)
                .font(.largeTitle)
                .padding()
                
                if differentiateWithoutColor || accessibilityEnabled {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                withAnimation {
                                    self.removeCard(at: self.cards.count - 1)
                                }
                            }) {
                                Image(systemName: "xmark.circle")
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .accessibility(label: Text("Wrong"))
                            .accessibility(hint: Text("Mark your answer as being incorrect."))
                            Spacer()

                            Button(action: {
                                withAnimation {
                                    self.removeCard(at: self.cards.count - 1)
                                }
                            }) {
                                Image(systemName: "checkmark.circle")
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .accessibility(label: Text("Correct"))
                            .accessibility(hint: Text("Mark your answer as being correct."))
                        }
                        .foregroundColor(.white)
                        .font(.largeTitle)
                    }
                }
            }
            .onReceive(timer) { time in
                guard self.isActive else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                }
                
                if self.timeRemaining == 0 {
                    self.showTimeOutAlert = true
                    self.timeOut()
                }
            }
            
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.isActive = false
            }
            
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                if self.cards.isEmpty == false {
                    self.isActive = true
                }
            }
            .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
                EditView()
            }
            .onAppear(perform: {
                resetCards()
                prepareHaptics()
            })
            
            .alert(isPresented: $showTimeOutAlert, content: {
                Alert(title: Text("Your Time is Out"), message: nil, primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Start Over"), action: resetCards))
            })
            
            .actionSheet(isPresented: $showSettingScreen) {
                ActionSheet(title: Text("Recycle Answers"), message: Text("Sends wrong answers back to the bottom"), buttons: [
                    .default(Text("On")) { recycleWrongAnswers = true },
                    .default(Text("Off")) { recycleWrongAnswers = false },
                    .cancel()
                ])
            }
            
    }
    
    func removeCard(at index: Int) {
        guard index >= 0 else { return }
        cards.remove(at: index)
        
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    //Runs custom haptic when time runs out
    func timeOut() {
        //Make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        //Convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: 10 * offset))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
