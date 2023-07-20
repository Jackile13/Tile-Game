//
//  AchievementView.swift
//  Tile Game
//
//  Created by Jack Allie on 26/1/2023.
//

import SwiftUI

struct AchievementView: View {
    
    @State var beatEasyMode = 0
    @State var beatMediumMode = 0
    @State var beatHardMode = 0
    @State var hardWins = 0
    @State var hardWinGoal = 10
    @State var beatHard10x10 = 0
    @State var remoteWin = 0
    @State var remoteWinSteak = 0
    @State var maxRemoteWinSteak = 0
    @State var captureAllCorners = 0
    
    var body: some View {
        
        ScrollView {
            AchievementInfoView(text: "That Was Too Easy", subText: "Beat easy AI", value: beatEasyMode, maxValue: 1)
            
            AchievementInfoView(text: "Getting Good At This Game", subText: "Beat medium AI", value: beatMediumMode, maxValue: 1)
            
            AchievementInfoView(text: "Mastermind", subText: "Beat hard AI", value: beatHardMode, maxValue: 1)
            
            AchievementInfoView(text: "Unbeatable", subText: "Beat hard AI \(hardWinGoal) times", value: hardWins, maxValue: hardWinGoal, showNumbers: true)
            
            AchievementInfoView(text: "The Ultimate Test", subText: "Beat hard AI on 10x10 grid", value: beatHard10x10, maxValue: 1)
            
            AchievementInfoView(text: "Wireless Victory", subText: "Win a remote game", value: remoteWin, maxValue: 1)
            
            AchievementInfoView(text: "Highest Remote Game Winsteak", subText: "Current Streak: \(remoteWinSteak)", value: maxRemoteWinSteak, maxValue: 1, showNumbers: true)
            
            AchievementInfoView(text: "Comfy Corners", subText: "Capture All Corners In One Match", value: captureAllCorners, maxValue: 1)
        }
        .navigationTitle("Achievements")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let a = AchievementLogger.instance
                if a.getBeatEasy() { beatEasyMode = 1 }
                if a.getBeatMedium() { beatMediumMode = 1 }
                if a.getBeatHard() { beatHardMode = 1 }
                if a.getBeatHard10x10() { beatHard10x10 = 1 }
                if a.getWinRemoteGame() { remoteWin = 1 }
                if a.getCaptureCorners() { captureAllCorners = 1 }
                
                hardWins = a.getBeatHardTimes()
                remoteWinSteak = a.getremoteWinStreak()
                maxRemoteWinSteak = a.getMaxRemoteWinStreak()
            }
        }
        
    }
}

struct AchievementInfoView: View {
    
    let text: String
    var subText: String? = nil
    let value: Int
    let maxValue: Int
    var showNumbers: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(text)
                if subText != nil {
                    Text(subText!)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            CircularProgressView(value: value, maxValue: maxValue, size: 50, showNumbers: showNumbers)
        }
        .padding()
        .background(Color("ButtonColour"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.5), radius: 1, x: 0, y: 0.5)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct CircularProgressView: View {
    
    let value: Int
    let maxValue: Int
    let size: CGFloat
    let showNumbers: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.5), lineWidth: (size / 6))
            Circle()
                .trim(from: 0, to: (CGFloat(value) / CGFloat(maxValue)))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: (size / 6), lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.75), value: value)
            if showNumbers {
                if maxValue == 1 {
                    Text("\(value)")
                        .animation(.easeInOut, value: value)
                } else {
                    Text("\(value)/\(maxValue)")
                        .font(.system(size: (size / 3)))
                        .animation(.easeInOut, value: value)
                }
            } else {
//                if (value == maxValue) {
                    Image(systemName: "crown.fill")
                        .scaleEffect(value == maxValue ? 1.0:0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.5), value: value)
                        .foregroundColor(Color.blue.opacity(0.5))
//                }
            }
        }
        .frame(width: size, height: size)
    }
}

struct AchievementView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementView()
    }
}
