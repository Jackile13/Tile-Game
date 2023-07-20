//
//  LocalGame.swift
//  Tile Game
//
//  Created by Jack Allie on 8/1/2023.
//
// Creates a grid of the given size
// Player 1 goes first
// An small square is aready filled in when each players colours alternating
// Game ends when all squares are filled
// Record statistics as game played, write statistics to statistics file at the end of the game
// At the end of the game, option to rematch or go to main menu

import SwiftUI

struct LocalGame: View {
    
    
    @Binding var navigation: [Int]
    
    @State var gameStarted = false
    @State var gameState: GameState
    @State var gameOver = false
    @State var gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var gameTimerFormatted: String = "0m 0s"
    @State var isPaused = false
    @State var gameTime = 0 {
        didSet {
            let minutes = Int(gameTime / 60)
            let seconds = gameTime - (minutes * 60)
            
            gameTimerFormatted = String(format: "%dm %ds", minutes, seconds)
        }
    }
    
    @State var p1TilesConverted = 0
    @State var p2TilesConverted = 0
    
    @State var currentAchievement: AchievementInfo? = nil
    @State var showAchievementNotif = false
    
    @Namespace var gridAnimation
    
    var body: some View {
        ZStack {
            VStack {
                // Game time and pause button
                HStack {
                    Text(gameTimerFormatted)
                    Spacer()
                    Button {
                        withAnimation {
                            isPaused = true
                        }
                    } label: {
                        Image(systemName: "pause.fill")
                            .foregroundColor(Color(uiColor: UIColor.white))
                            .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 7.5)
                                    .foregroundColor(Color.blue)
                                    .shadow(color: Color.gray.opacity(0.5), radius: 2, y: 1)
                            }
                    }
                }
                
                // Player info views
                HStack {
                    PlayerInfoView(player: gameState.player1, alignment: .leading, tilesRemaining: $gameState.playerTiles1, score: $gameState.playerScore1)
                    Spacer()
                    PlayerInfoView(player: gameState.player2, alignment: .trailing, tilesRemaining: $gameState.playerTiles2, score: $gameState.playerScore2)
                }
                
                Spacer()
                
                // Game Grid
                if !gameOver {
                    GameGrid(gameState: $gameState, gameOver: $gameOver, isPaused: $isPaused, p1TilesConverted: $p1TilesConverted, p2TilesConverted: $p2TilesConverted, currentAchievement: $currentAchievement, showAchievementNotif: $showAchievementNotif)
                        .matchedGeometryEffect(id: 0, in: gridAnimation)
                        .padding(.vertical)
                } else {
                    GameGrid(gameState: $gameState, gameOver: $gameOver, isPaused: $isPaused, p1TilesConverted: $p1TilesConverted, p2TilesConverted: $p2TilesConverted, currentAchievement: $currentAchievement, showAchievementNotif: $showAchievementNotif)
                        .opacity(0.0001)
                        .disabled(true)
                        .padding(.vertical)
                }
                
                // Turn indicator
                Text(gameState.currentTurn.name + "'s turn")
                    .monospaced()
                    .padding(7.5)
                    .foregroundColor(.white)
                    .background {
                        Color(gameState.currentTurn.colour)
                            .cornerRadius(10)
                    }
                
                Spacer()
                Spacer()
            }
            .padding()
            .blur(radius: isPaused ? 5:0)
            .disabled(isPaused)
            .scaleEffect(isPaused ? 0.98:1.0)
            
            // Pause menu
            if isPaused && !gameOver { GamePauseMenu(isPaused: $isPaused, navigation: $navigation).zIndex(10) }
            
            // Game Over Screen
            if gameOver { GameEndScreen(gridAnimation: gridAnimation, gameState: $gameState, isPaused: $isPaused, gameOver: $gameOver, gameTime: $gameTimerFormatted, navigation: $navigation).zIndex(10) }
            
            
            VStack {
                if showAchievementNotif {
                    AchievementNotification(achievement: $currentAchievement, show: $showAchievementNotif)
                        .animation(.easeInOut, value: showAchievementNotif)
                        .transition(.move(edge: .top))
                        .frame(maxWidth: 500)
                }
                Spacer()
            }
            .zIndex(11)
//            .padding(.top)
            
            
        }
        .background(Color("AltBackground"))
        .onAppear(perform: initGameGrid)
        .onChange(of: gameOver, perform: { _ in
            if gameOver == false {
                gameStarted = false
                initGameGrid()
                p1TilesConverted = 0
                p2TilesConverted = 0
                gameTime = 0
            }
            if gameOver == true {
                saveStats()
                updatePostGameAchievements()
            }
        })
        .navigationBarBackButtonHidden()
        .onReceive(gameTimer) { _ in
            if !isPaused {
                gameTime += 1
            }
        }
//        .onAppear() {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                setCurrentAchievement(AchievementInfo(text: "Test", subText: "Testing"))
//            }
//        }
    }
    
    private func initGameGrid() {
        guard !gameStarted else { return }
        // Initialise grid
        for _ in 0..<gameState.gridSize {
            gameState.grid.append(Array(repeating: .empty, count: gameState.gridSize))
        }
        
        // Find start of center square
        let centre00 = gameState.gridSize / 2 - 1
        
        // Set all squares to empty
        for y in 0..<gameState.gridSize {
            for x in 0..<gameState.gridSize {
                gameState.grid[x][y] = .empty
            }
        }
        
        // Set the intial tiles
        gameState.grid[centre00][centre00] = .p1
        gameState.grid[centre00][centre00 + 1] = .p2
        gameState.grid[centre00 + 1][centre00] = .p2
        gameState.grid[centre00 + 1][centre00 + 1] = .p1
        
        // Set the "can be placed on" tiles
        gameState.grid[centre00 - 1][centre00 - 1] = .canBePlacedOn
        gameState.grid[centre00 - 1][centre00] = .canBePlacedOn
        gameState.grid[centre00][centre00 - 1] = .canBePlacedOn
        
        gameState.grid[centre00 - 1][centre00 + 2] = .canBePlacedOn
        gameState.grid[centre00 - 1][centre00 + 1] = .canBePlacedOn
        gameState.grid[centre00][centre00 + 2] = .canBePlacedOn
        
        gameState.grid[centre00 + 1][centre00 - 1] = .canBePlacedOn
        gameState.grid[centre00 + 2][centre00] = .canBePlacedOn
        gameState.grid[centre00 + 2][centre00 - 1] = .canBePlacedOn
        
        gameState.grid[centre00 + 2][centre00 + 2] = .canBePlacedOn
        gameState.grid[centre00 + 1][centre00 + 2] = .canBePlacedOn
        gameState.grid[centre00 + 2][centre00 + 1] = .canBePlacedOn
        
        gameStarted = true
    }
    
    private func saveStats() {
        let stats = LocalStatistics(state: gameState, duration: gameTime, p1TilesConverted: p1TilesConverted, p2TilesConverted: p2TilesConverted)
        
        DispatchQueue.global().async {
            MainStatistics.saveStats(stats, to: MainStatistics.localStatsPath)
        }
    }
    
    /**
     Updates achievement progress for local post game relevant achievemnets
     */
    private func updatePostGameAchievements() {
        if (gameState.player1.type == .human && gameState.player2.type == .AI(.easy)) && (gameState.playerScore1 > gameState.playerScore2) {
            // Player beat easy AI
            if !AchievementLogger.instance.getBeatEasy() {
                setCurrentAchievement(AchievementInfo(text: "That Was Too Easy", subText: "Beat easy AI"))
                AchievementLogger.instance.setBeatEasy()
            }
        }
        if  (gameState.player1.type == .AI(.easy) && gameState.player2.type == .human) && (gameState.playerScore1 < gameState.playerScore2) {
            // Player beat easy AI
            if !AchievementLogger.instance.getBeatEasy() {
                setCurrentAchievement(AchievementInfo(text: "That Was Too Easy", subText: "Beat easy AI"))
                AchievementLogger.instance.setBeatEasy()
            }
        }
        if (gameState.player1.type == .human && gameState.player2.type == .AI(.medium)) && (gameState.playerScore1 > gameState.playerScore2) {
            // Player beat medium AI
            if !AchievementLogger.instance.getBeatMedium() {
                setCurrentAchievement(AchievementInfo(text: "Getting Good At This Game", subText: "Beat medium AI"))
                AchievementLogger.instance.setBeatMedium()
            }
        }
        if (gameState.player1.type == .AI(.medium) && gameState.player2.type == .human) && (gameState.playerScore1 < gameState.playerScore2) {
            // Player beat medium AI
            if !AchievementLogger.instance.getBeatMedium() {
                setCurrentAchievement(AchievementInfo(text: "Getting Good At This Game", subText: "Beat medium AI"))
                AchievementLogger.instance.setBeatMedium()
            }
        }
        if (gameState.player1.type == .human && gameState.player2.type == .AI(.hard)) && (gameState.playerScore1 > gameState.playerScore2) {
            // Player beat hard AI
            
            if AchievementLogger.instance.getBeatHardTimes() == 0 {
                setCurrentAchievement(AchievementInfo(text: "Mastermind", subText: "Beat hard AI"))
            }
            
            if gameState.gridSize == 10 {
                if !AchievementLogger.instance.getBeatHard10x10() {
                    setCurrentAchievement(AchievementInfo(text: "The Ultimate Test", subText: "Beat hard AI on 10x10 grid"))
                }
                // Also increments beat hard
                AchievementLogger.instance.setBeatHard10x10()
            } else {
                AchievementLogger.instance.incrementBeatHard()
            }
        }
        if (gameState.player1.type == .AI(.hard) && gameState.player2.type == .human) && (gameState.playerScore1 < gameState.playerScore2) {
            // Player beat hard AI
            
            if AchievementLogger.instance.getBeatHardTimes() == 0 {
                setCurrentAchievement(AchievementInfo(text: "Mastermind", subText: "Beat hard AI"))
            }
            
            if gameState.gridSize == 10 {
                if !AchievementLogger.instance.getBeatHard10x10() {
                    setCurrentAchievement(AchievementInfo(text: "The Ultimate Test", subText: "Beat hard AI on 10x10 grid"))
                }
                // Also increments beat hard
                AchievementLogger.instance.setBeatHard10x10()
            } else {
                AchievementLogger.instance.incrementBeatHard()
            }
        }
        
        if AchievementLogger.instance.getBeatHardTimes() == 10 {
            setCurrentAchievement(AchievementInfo(text: "Unbeatable", subText: "Beat hard AI 10 times"))
        }
        
    }
    
    private func setCurrentAchievement(_ a: AchievementInfo) {
        if currentAchievement == nil {
            withAnimation {
                showAchievementNotif = true
            }
            currentAchievement = a
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { setCurrentAchievement(a) })
        }
    }
}



struct PlayerInfoView: View {
    
    let player: Player
    let alignment: HorizontalAlignment
    
    @Binding var tilesRemaining: Int
    @Binding var score: Int
    
    var body: some View {
        VStack(alignment: alignment) {
            HStack(alignment: .center) {
                Text(player.name)
                    .bold()
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color(player.colour))
                    .frame(width: 20, height: 20)
            }
            Text("Tiles: \(tilesRemaining)")
            Text("Score: \(score)")
        }.monospaced()
    }
}


struct GamePauseMenu: View {
    
    @Binding var isPaused: Bool
    @Binding var navigation: [Int]
    
    var body: some View {
        VStack {
            Text("Game Paused")
                .foregroundColor(.primary)
                .padding(.bottom, 35)
                .font(.title)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
            Group {
                NavigationLink("Help") {
                    Help()
                }
                Button("Quit Game"){
//                    NavigationUtil.popToRootView()
                    navigation.removeAll()
                }
            }
            .font(.headline)
            .foregroundColor(Color.primary)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 50)
                    .foregroundColor(Color("ButtonColour"))
                    .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
            }
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
            
            
            Button("Continue Game") {
                withAnimation {
                    isPaused = false
                }
            }
            .font(.headline)
            .foregroundColor(Color(uiColor: .white))
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 50)
                    .foregroundColor(Color.blue)
                    .shadow(radius: 2, y: 1)
            }
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
        }
        .foregroundColor(Color(uiColor: UIColor.white))
        .padding(.horizontal, 60)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color("Background"))
                .shadow(radius: 2, y: 1)
        }
    }
}


struct GameEndScreen: View {
    
    var gridAnimation: Namespace.ID
    
    @Binding var gameState: GameState
    @Binding var isPaused: Bool
    @Binding var gameOver: Bool
    @Binding var gameTime: String
    @Binding var navigation: [Int]
    
    @State var showStuff = false
    
    var body: some View {
        VStack {
            if showStuff{
                Group {
                    if gameState.playerScore1 > gameState.playerScore2 {
                        Text(gameState.player1.name + " wins!")
                    } else if gameState.playerScore2 > gameState.playerScore1 {
                        Text(gameState.player2.name + " wins!")
                    } else {
                        Text("Draw!")
                    }
                }
                .foregroundColor(.primary)
                .font(.title)
                .monospaced()
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
            }
            
            GameGrid(gameState: $gameState, gameOver: .constant(true), isPaused: .constant(true), p1TilesConverted: .constant(0), p2TilesConverted: .constant(0), currentAchievement: .constant(nil), showAchievementNotif: .constant(false))
                .padding(7.5)
                .cornerRadius(15)
                .offset(y: -40)
                .padding(.bottom, -40)
                .scaleEffect(0.75)
                .matchedGeometryEffect(id: 0, in: gridAnimation)
                .disabled(true)
                
            
            if showStuff {
                
                Group {
                    HStack {
                        Spacer()
                        Text("Score: ")
                        Spacer()
                        Text("\(gameState.playerScore1) - \(gameState.playerScore2)")
                        Spacer()
                    }
                    .minimumScaleFactor(0.75)
                    
                    HStack {
                        Spacer()
                        Text("Time: ")
                        Spacer()
                        Text(gameTime)
                        Spacer()
                    }
                    .minimumScaleFactor(0.75)
                }
                .foregroundColor(.primary)
                .monospaced()
                
                HStack {
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            isPaused = false
                            gameOver = false
                        }
                        gameState = GameState(gridSize: gameState.gridSize, player1: gameState.player1, player2: gameState.player2)
                    } label: {
                        Text("Rematch")
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                    }
                    .font(.headline)
                    .foregroundColor(Color.primary)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 50)
                            .foregroundColor(Color("ButtonColour"))
                            .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                    }
                    
                    Spacer()
                    
                    Button("Main Menu") {
                        navigation.removeAll()
                    }
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 50)
                            .foregroundColor(Color.blue)
                            .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                    }
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    
                    Spacer()
                }
            }
        }
        .foregroundColor(Color(uiColor: UIColor.white))
        .padding()
        .background {
            if showStuff {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color("Background"))
                    .shadow(radius: 2, y: 1)
            }
        }
        .padding()
        .onAppear() {
            
            Utils.numPlayedSession += 1
            Utils.playSound(Utils.gameEndSoundURL)
//            UINotificationFeedbackGenerator().notificationOccurred(.success)
            Utils.playSuccessHaptic()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation {
                    showStuff = true
                }
            }
            
            // Temp
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                // Auto rematch
//                isPaused = false
//                gameOver = false
//                gameState = GameState(gridSize: gameState.gridSize, player1: gameState.player1, player2: gameState.player2)
//            }
        }
        .frame(maxWidth: 500)
    }
}

struct LocalGame_Previews: PreviewProvider {
    static var previews: some View {
        LocalGame(navigation: .constant([]), gameState: GameState(gridSize: 6,
                                       player1: Player(name: "Player 1", number: 1, type: .human, colour: "Red"),
                                       player2: Player(name: "Player 2", number: 2, type: .human, colour: "Green")))
    }
}
