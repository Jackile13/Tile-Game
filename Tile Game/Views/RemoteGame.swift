//
//  RemoteGame.swift
//  Tile Game
//
//  Created by Jack Allie on 17/1/2023.
//

import SwiftUI

struct RemoteGame: View {
    
    @Binding var connectionService: ConnectionService
    @Binding var navigation: [Int]
    
    @State var hasStarted = false
    
    @State var canPlay = false
    @State var clientType: ClientType
    @State var gameState: GameState //= GameState(gridSize: 8, player1: Player(name: "", number: 1, type: .human, colour: "red"), player2: Player(name: "", number: 1, type: .human, colour: "red"))
    @State var gameOver = false
    @State var gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var gameTimerFormatted: String = "0m 0s"
    @State var isPaused = false
    @State var quitGame = false
    @State var otherPlayerQuit = false
    @State var otherPlayerRematch = false
    @State var rematch = false
    @State var gameTime = 0 {
        didSet {
            let minutes = Int(gameTime / 60)
            let seconds = gameTime - (minutes * 60)
            
            gameTimerFormatted = String(format: "%dm %ds", minutes, seconds)
        }
    }
    
    @State var showAchievementNotif = false
    @State var currentAchievement: AchievementInfo? = nil
    
    @State var p1TilesConverted = 0
    @State var p2TilesConverted = 0
    
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
                        connectionService.sendMessage(msg: Message(key: .pause, value: "true"))
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
                    if clientType == .host {
                        PlayerInfoView(player: gameState.player1, alignment: .leading, tilesRemaining: $gameState.playerTiles1, score: $gameState.playerScore1)
                        Spacer()
                        PlayerInfoView(player: gameState.player2, alignment: .trailing, tilesRemaining: $gameState.playerTiles2, score: $gameState.playerScore2)
                    } else {
                        PlayerInfoView(player: gameState.player2, alignment: .leading, tilesRemaining: $gameState.playerTiles1, score: $gameState.playerScore1)
                        Spacer()
                        PlayerInfoView(player: gameState.player1, alignment: .trailing, tilesRemaining: $gameState.playerTiles2, score: $gameState.playerScore2)
                    }
                }
                
                Spacer()
                
                // Game Grid
                if !gameOver {
                    GameGridRemote(isMessageDelegate: true, gameState: $gameState, gameOver: $gameOver, isPaused: $isPaused, canPlay: $canPlay, clientType: $clientType, connectionService: $connectionService, otherPlayQuit: $otherPlayerQuit, otherPlayerRematch: $otherPlayerRematch, p1TilesConverted: $p1TilesConverted, p2TilesConverted: $p2TilesConverted, currentAchievement: $currentAchievement, showAchievementNotif: $showAchievementNotif)
                        .matchedGeometryEffect(id: 0, in: gridAnimation)
                        .padding(.vertical)
                        .onAppear() {
                            canPlay = clientType == .host
                        }
                } else {
                    GameGrid(gameState: $gameState, gameOver: $gameOver, isPaused: $isPaused, p1TilesConverted: $p1TilesConverted, p2TilesConverted: $p2TilesConverted, currentAchievement: .constant(nil), showAchievementNotif: .constant(false))
                        .opacity(0.0001)
                        .disabled(true)
                        .padding(.vertical)
                }
                
                // Turn indicator
                    if clientType == .host {
                        Text(gameState.currentTurn.name + "'s turn")
                            .monospaced()
                            .padding(7.5)
                            .foregroundColor(.white)
                            .background {
                                Color(gameState.currentTurn.colour)
                                    .cornerRadius(10)
                            }
                    } else {
                        // client
                        Text(gameState.currentTurn.number == gameState.player1.number ? (gameState.player2.name + "'s turn"):(gameState.player1.name + "'s turn"))
                            .monospaced()
                            .padding(7.5)
                            .foregroundColor(.white)
                            .background {
                                Color(gameState.currentTurn.number == gameState.player1.number ? (gameState.player2.colour):(gameState.player1.colour))
                                    .cornerRadius(10)
                            }
                    }
                
                Spacer()
                Spacer()
            }
            .padding()
            .blur(radius: isPaused ? 5:0)
            .disabled(isPaused)
            .scaleEffect(isPaused ? 0.98:1.0)
            
            // Pause menu
            if isPaused && !gameOver { GamePauseMenuRemote(connectionService: $connectionService, isPaused: $isPaused, quitGame: $quitGame).zIndex(10) }
            
            // Game Over Screen
            if gameOver { GameEndScreenRemote(gridAnimation: gridAnimation, gameState: $gameState, isPaused: $isPaused, gameOver: $gameOver, gameTime: $gameTimerFormatted, quitGame: $quitGame, rematch: $rematch, otherPlayerRematch: $otherPlayerRematch, connectionService: $connectionService, clientType: $clientType).zIndex(10) }
            
            VStack {
                if showAchievementNotif {
                    AchievementNotification(achievement: $currentAchievement, show: $showAchievementNotif)
                        .animation(.easeInOut, value: showAchievementNotif)
                        .transition(.move(edge: .top))
                }
                Spacer()
            }
            .frame(maxWidth: 500)
            .zIndex(11)
//            .padding(.top)
            
        }
        .alert("Lost connection", isPresented: $otherPlayerQuit, actions: {
            Button("Ok") {
                navigation.removeAll()
            }
        })
        .alert("Quit Game?", isPresented: $quitGame, actions: {
            Button("Quit") {
                navigation.removeAll()
                connectionService.sendMessage(msg: Message(key: .quit, value: ""))
            }
            Button("Cancel") {
                quitGame = false
            }
        }, message: {
            Text("You will be disconnected from the remote play session.")
        })
        .background(Color("AltBackground"))
        .onAppear {
            initGameGrid() }
        .onChange(of: gameOver, perform: { _ in
            if gameOver == false {
                hasStarted = false
                initGameGrid()
                p1TilesConverted = 0
                p2TilesConverted = 0
                gameTime = 0
            } else {
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
        .onChange(of: rematch) { _ in
            connectionService.sendMessage(msg: Message(key: .rematch, value: rematch))
        }
    }
    
    
    private func initGameGrid() {
        guard !hasStarted else { return }
        
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
        
        hasStarted = true
    }
    
    private func saveStats() {
        let stats = RemoteStatistics(state: gameState, didHost: clientType == .host, duration: gameTime, p1TilesConverted: p1TilesConverted, p2TilesConverted: p2TilesConverted)
        
        DispatchQueue.global().async {
            MainStatistics.saveStats(stats, to: MainStatistics.remoteStatsPath)
        }
    }
    
    /**
     Updates achievements for remote post game
     */
    private func updatePostGameAchievements() {
        
        if clientType == .host {
            if gameState.playerScore1 > gameState.playerScore2 {
                // If is host and did win the game
                if !AchievementLogger.instance.getWinRemoteGame() {
                    setCurrentAchievement(AchievementInfo(text: "Wireless Victory", subText: "Win a remote game"))
                }
                AchievementLogger.instance.wonRemoteGame()
            } else {
                AchievementLogger.instance.lostRemoteGame()
            }
        }
        
        if clientType == .client {
            if gameState.playerScore2 > gameState.playerScore1 {
                // If is client and did win the game
                if !AchievementLogger.instance.getWinRemoteGame() {
                    setCurrentAchievement(AchievementInfo(text: "Wireless Victory", subText: "Win a remote game"))
                }
                AchievementLogger.instance.wonRemoteGame()
            } else {
                AchievementLogger.instance.lostRemoteGame()
            }
        }
        
        if AchievementLogger.instance.getremoteWinStreak() == 10 {
            setCurrentAchievement(AchievementInfo(text: "10 Winsteak!", subText: "Win 10 remote matches in a row"))
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

struct GameEndScreenRemote: View {
    
    var gridAnimation: Namespace.ID
    
    @Binding var gameState: GameState
    @Binding var isPaused: Bool
    @Binding var gameOver: Bool
    @Binding var gameTime: String
    @Binding var quitGame: Bool
    @Binding var rematch: Bool
    @Binding var otherPlayerRematch: Bool
    @Binding var connectionService: ConnectionService
    @Binding var clientType: ClientType
    
    @State var showStuff = false
    @State var winnerText = ""
    
    var body: some View {
        VStack {
            if showStuff{
                Text(winnerText)
                    .foregroundColor(.primary)
                    .font(.title)
                    .monospaced()
            }
            
//            GameGrid(gameState: $gameState, gameOver: .constant(true), isPaused: .constant(true))
            GameGridRemote(gameState: $gameState, gameOver: .constant(true), isPaused: .constant(true), canPlay: .constant(false), clientType: $clientType, connectionService: $connectionService, otherPlayQuit: .constant(false), otherPlayerRematch: .constant(false), p1TilesConverted: .constant(0), p2TilesConverted: .constant(0), currentAchievement: .constant(nil), showAchievementNotif: .constant(false))
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
                    
                    HStack {
                        Spacer()
                        Text("Time: ")
                        Spacer()
                        Text(gameTime)
                        Spacer()
                    }
                }
                .foregroundColor(.primary)
                .monospaced()
                
                HStack(spacing: 30) {
                    
                    Button(rematch ? "Cancel ":"Rematch") {
                        rematch.toggle()
                    }
                    .font(.headline)
                    .foregroundColor(Color.primary)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 50)
                            .foregroundColor(Color("ButtonColour"))
                            .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                    }
                    
                    Button("Main Menu") {
                        quitGame = true
                    }
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 50)
                            .foregroundColor(Color.blue)
                            .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                    }
                }
            }
            Text("Other player is ready for a rematch!")
                .foregroundColor(.gray)
                .font(.subheadline)
                .opacity(otherPlayerRematch ? 1:0)
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
            
            if gameState.playerScore2 == gameState.playerScore1 { winnerText = "Draw!" }
            else {
                if clientType == .host {
                    if gameState.playerScore1 > gameState.playerScore2 {
                        winnerText = "Player 1 wins!"
                    } else {
                        winnerText = "Player 2 wins!"
                    }
                } else {
                    if gameState.playerScore1 > gameState.playerScore2 {
                        winnerText = "Player 1 wins!"
                    } else {
                        winnerText = "Player 2 wins!"
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation {
                    showStuff = true
                }
            }
        }
        .onChange(of: rematch && otherPlayerRematch) { bothRematch in
            if bothRematch {
                withAnimation {
                    isPaused = false
                    gameOver = false
                }
                gameState = GameState(gridSize: gameState.gridSize, player1: gameState.player1, player2: gameState.player2)
                rematch = false
                otherPlayerRematch = false
                showStuff = false
            }
        }
        .frame(maxWidth: 500)
    }
}

struct GamePauseMenuRemote: View {
    
    @Binding var connectionService: ConnectionService
    @Binding var isPaused: Bool
    @Binding var quitGame: Bool
    
    var body: some View {
        VStack {
            Text("Game Paused")
                .foregroundColor(.primary)
                .padding(.bottom, 35)
                .font(.title)
            Group {
                NavigationLink("Help") {
                    Help()
                }
                Button("Quit Game"){
                    quitGame = true
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
            
            
            Button("Continue Game") {
                withAnimation {
                    isPaused = false
                }
                connectionService.sendMessage(msg: Message(key: .pause, value: "false"))
            }
            .font(.headline)
            .foregroundColor(Color(uiColor: .white))
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 50)
                    .foregroundColor(Color.blue)
                    .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
            }
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

struct RemoteGame_Previews: PreviewProvider {
    static var previews: some View {
//        RemoteGame(connectionService: .constant(ConnectionService()), clientType: .host, gameState: GameState(gridSize: 8, player1: Player(name: "p1", number: 1, type: .human, colour: "Red"), player2: Player(name: "p2", number: 2, type: .human, colour: "Dark Blue")))
        RemoteGame(connectionService: .constant(ConnectionService()), navigation: .constant([]), clientType: .host, gameState: GameState(gridSize: 8, player1: Player(name: "p1", number: 1, type: .human, colour: "Red"), player2: Player(name: "p2", number: 2, type: .human, colour: "Dark Blue")))
    }
}
