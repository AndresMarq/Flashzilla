//
//  CardView.swift
//  Flashzilla
//
//  Created by Andres Marquez on 2021-08-23.
//

import SwiftUI

struct CardView: View {
    let card: Card
    
    var removal: ((Bool) -> Void)? = nil
    
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    
    @State private var feedback = UINotificationFeedbackGenerator()
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                        ? Color.white
                        : Color.white
                            .opacity(1 - Double(abs(offset.width / 50)))

                )
                .background(
                    differentiateWithoutColor
                        ? nil
                        : RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(self.cardColor(offset: offset.width))
                )
                .shadow(radius: 10)
            
            VStack {
                if accessibilityEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)

                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(Double(offset.width / 50)))
        .offset(x: offset.width * 5, y: 0)
        .opacity(2 - Double(offset.width / 50))
        .accessibility(addTraits: .isButton)
        .gesture(
            DragGesture()
                .onChanged { offset in
                    self.offset = offset.translation
                    self.feedback.prepare()
                }
                .onEnded { _ in
                    if abs(self.offset.width) > 100 {
                        var rightAnswer: Bool
                        
                        if self.offset.width > 0 {
                            self.feedback.notificationOccurred(.success)
                            rightAnswer = true
                        } else {
                            self.feedback.notificationOccurred(.error)
                           rightAnswer = false
                        }

                        self.removal?(rightAnswer)
                    }
                    self.offset = .zero
                }
        )
        .onTapGesture {
            self.isShowingAnswer.toggle()
        }
        .animation(.spring())
    }
    
    func cardColor(offset: CGFloat) -> Color {
        if offset > 0 {
            return .green
        } else if offset < 0 {
            return .red
        } else {
            return .white
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example)
    }
}
