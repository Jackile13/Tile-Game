//
//  StartView.swift
//  Tile Game
//
//  Created by Jack Allie on 8/1/2023.
//
// The home screen of the game
// Can select local or server play
// Has buttons for statistics and info/settings

import SwiftUI
import StoreKit

struct StartView: View {
    let smallPulsate = 0.9
    let largePulsate = 1.1
    let pulsateDuration = 3
    
    @Environment(\.requestReview) var requestReview
    
    @State var navigation: [Int] = []
    
    @State var pulsateTitle = 0.9
    
    
    @State var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack(path: $navigation) {
            VStack {
                
                Spacer()
                
                Text("Parille")
                    .font(.system(size: 45, weight: .medium, design: .monospaced))
                    .scaleEffect(pulsateTitle)
                
                Spacer()
                
                VStack() {
                    NavigationLink(value: 0) {
                        LargeMenuButton(text: "Local Play")
                            .frame(maxWidth:450)
                    }.padding()
                    
                    NavigationLink(value: 1) {
                        LargeMenuButton(text: "Remote Play")
                            .frame(maxWidth:450)
                    }.padding()
                    
                }.padding(.horizontal)
                    .navigationDestination(for: Int.self) { value in
                        if value == 0 { PlayerSelectView(navigation: $navigation) }
                        else { ServerSelectView(navigation: $navigation) }
                    }
                
                Spacer()
                
                HStack {
                    NavigationLink {
                        // Stats
                        StatisticsView()
                    } label: {
                        SmallMenuButton(iconName: "chart.bar.xaxis")
                    }
                    
                    NavigationLink {
                        // Achievements
                        AchievementView()
                    } label: {
                        SmallMenuButton(iconName: "rosette")
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        // Info/settings
                        Settings()
                    } label: {
                        SmallMenuButton(iconName: "info.circle")
                    }
                }.padding()
                
            }
            .background(StartBackgroundView())
            .onAppear() {
                print("APPEAR")
                if Utils.canReqReview() {
                    requestReview()
                }
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: Double(pulsateDuration))) {
                if pulsateTitle == smallPulsate { pulsateTitle = largePulsate }
                else { pulsateTitle = smallPulsate }
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}

struct StartBackgroundView: View {
    
    let maxOffset: CGFloat = UIScreen.main.bounds.width/2
    
    var body: some View {
        VStack(spacing: 55) {
            ForEach(0..<14) { _ in
                let size = CGFloat.random(in: 15...60)
                Rectangle()
                    .frame(width: size, height: size)
                    .foregroundColor(colours[Int.random(in: 0..<colours.count)])
                    .offset(x: CGFloat.random(in: -maxOffset...maxOffset))
//                    .animation(nil, value: maxOffset)
            }
        }
        .blur(radius: 15)
        .ignoresSafeArea()
    }
}

struct LargeMenuButton: View {
    let text: String
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Divider()
                    .foregroundColor(.clear)
                    .frame(height: 1)
            }
            Text(text)
        }
        .padding(.vertical, 30)
        .foregroundColor(.primary)
        .font(.system(size: 35, weight: .medium, design: .monospaced))
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color("ButtonColour"))
                .shadow(color: Color.gray.opacity(0.5), radius: 2, y: 1)
                .opacity(0.70)
        }
    }
}

struct SmallMenuButton: View {
    let iconName: String
    
    var body: some View {
        Image(systemName: iconName)
            .padding()
            .foregroundColor(.primary)
            .font(.system(size: 20, weight: .medium, design: .monospaced))
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("ButtonColour"))
                    .shadow(color: Color.gray.opacity(0.5), radius: 2, y: 1)
                    .opacity(0.70)
            }
    }
}

