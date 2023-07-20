//
//  AchievementNotification.swift
//  Tile Game
//
//  Created by Jack Allie on 27/1/2023.
//

import SwiftUI

struct AchievementNotification: View {
    
//    let text: String
//    let subText: String
    
//    @Binding var achievement: AchievementInfo?
    @Binding var achievement: AchievementInfo?
    @Binding var show: Bool
    
    @State var textOnly = true
    @State var value = 0
    
    @Namespace var animation
    
    var body: some View {
        HStack {
            if textOnly {
                Spacer()
                Text(achievement?.text ?? "")
                    .font(.largeTitle)
                    .minimumScaleFactor(0.5)
                    .matchedGeometryEffect(id: "text", in: animation)
                Spacer()
            } else {
                VStack(alignment: .leading) {
                    Text(achievement?.text ?? "")
                        .font(.title)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .matchedGeometryEffect(id: "text", in: animation)
                    Text(achievement?.subText ?? "")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.leading)
                Spacer()
                CircularProgressView(value: value, maxValue: 1, size: 50, showNumbers: false)
                    .padding()
            }
        }
        .frame(height: 100)
        .background(Color(uiColor: UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 2, x: 0, y: 1)
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                Utils.playSound(Utils.achieveSoundURL)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) { textOnly = false }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                value = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    show = false
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                achievement = nil
            }
        }
    }
}


struct AchievementNotification_Previews: PreviewProvider {
    static var previews: some View {
        AchievementNotification(achievement: .constant(nil), show: .constant(true))
    }
}
