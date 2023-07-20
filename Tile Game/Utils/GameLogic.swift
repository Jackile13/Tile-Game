//
//  File.swift
//  Tile Game
//
//  Created by Jack Allie on 17/1/2023.
//

import Foundation
import SwiftUI
import AVFoundation

struct GameGrid: View {
    @Binding var gameState: GameState
    @Binding var gameOver: Bool
    @Binding var isPaused: Bool
    @Binding var p1TilesConverted: Int
    @Binding var p2TilesConverted: Int
    @Binding var currentAchievement: AchievementInfo?
    @Binding var showAchievementNotif: Bool
    @State var AILoop = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    @State var AILoop = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var canPlay = true
    
    @State var rotated = [(row: Int, col: Int)]()
    
    
    var body: some View {
        GeometryReader { g in
            Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                ForEach(0..<gameState.grid.count, id: \.self) { row in
                    GridRow {
                        ForEach(0..<gameState.grid.count, id: \.self) { col in
                            Rectangle()
                                .foregroundColor(getSquareColor(row: row, col: col))
                                .frame(width: g.size.width / CGFloat(gameState.gridSize) - 2, height: g.size.width / CGFloat(gameState.gridSize) - 2)
                                .cornerRadius(5)
                                .onTapGesture {
                                    if gameState.currentTurn.type == .human && canPlay {
                                        handleAction(row: row, col: col)
                                    }
                                }
                                .rotation3DEffect(getRotation(col: col, row: row), axis: (0,1,0))
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            // If the first player is an AI, get it started
            if gameState.currentTurn.type != .human {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let move = gameState.currentTurn.AIStrategy?.makeMove(gameState: gameState)
                    if let move = move { handleAction(row: move.row, col: move.col) }
                }
            }
        }
        .onReceive(AILoop) { _ in
            // If next player is AI make a decision
            if gameState.currentTurn.type != .human && !isPaused {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let move = gameState.currentTurn.AIStrategy?.makeMove(gameState: gameState)
                    if let move = move { handleAction(row: move.row, col: move.col) }
                }
                // Fasty mode:
//                    let move = gameState.currentTurn.AIStrategy?.makeMove(gameState: gameState)
//                    if let move = move { handleAction(row: move.row, col: move.col) }
            }
        }
    }
    
    private func getRotation(col: Int, row: Int) -> Angle {
        let filtered = rotated.filter( { $0.row == row && $0.col == col })
        if filtered.isEmpty { return .zero }
        else { return .degrees(180) }
    }
    
    private func getSquareColor(row: Int, col: Int) -> Color {

        switch gameState.grid[col][row] {
        case .empty: return Color(uiColor: .systemGray5)
        case .canBePlacedOn: return Color(uiColor: .systemGray3)
        case .p1: return Color(gameState.player1.colour)
        case .p2: return Color(gameState.player2.colour)
        }
    }
    
    private func handleAction(row: Int, col: Int) {
        
        canPlay = false
        
        if gameOver { return }
        
        if gameState.grid[col][row] == .canBePlacedOn {
            let convertTo: GameGridSqaure
            if gameState.currentTurn.number == 1 { convertTo = .p1 } else { convertTo = .p2 }
            
            
            // Convert current square
            //            gameState.grid[col][row] = convertTo
            convertSquare(row: row, col: col, convertTo: convertTo, flip: false, fade: true)
            if gameState.currentTurn.type == .human {
                Utils.playSound(withVolume: 0.1, url: Utils.tilePlacedURL)
//                UISelectionFeedbackGenerator().selectionChanged()
                Utils.playLightHaptic()
            }
            
            
            // Convert connections
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                convertCol(row: row, col: col, to: convertTo)
                convertRow(row: row, col: col, to: convertTo)
                convertDiagonals(row: row, col: col, to: convertTo)
                
                updateScore()
                updateAchievements()
            }
            
            
            // Update the "can be placed on" squares
            // Create a 3x3 grid around the tapped square, convert all empty sqaures
            for c in (col-1)...(col+1) {
                for r in (row-1)...(row+1) {
                    if c < 0 || c >= gameState.gridSize || r < 0 || r >= gameState.gridSize { continue; }
                    if gameState.grid[c][r] == .empty { convertSquare(row: r, col: c, convertTo: .canBePlacedOn, flip: false, fade: true) }
                }
            }
            
            
            // Update player tiles information
            if convertTo == .p1 {
                gameState.playerTiles1 -= 1
            } else {
                gameState.playerTiles2 -= 1
            }
            
            // Next player's turn
            gameState.toggleTurn()
            
            // Check for end of game
            checkEndGame()
            
            if gameOver { return }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { canPlay = true }
    }
    
    private func updateAchievements() {
        // If haven't captured corners, check if corners were captured
        if !AchievementLogger.instance.getCaptureCorners() {
            let cornerCheck: GameGridSqaure?
            if (gameState.player1.type == .human) {
                cornerCheck = .p1
            } else if (gameState.player2.type == .human) {
                cornerCheck = .p2
            } else {
                cornerCheck = nil
            }
            
            if let cornerCheck {
                if (gameState.grid[0][0] == cornerCheck &&
                    gameState.grid[0][gameState.gridSize-1] == cornerCheck &&
                    gameState.grid[gameState.gridSize-1][0] == cornerCheck &&
                    gameState.grid[gameState.gridSize-1][gameState.gridSize-1] == cornerCheck) {
                    setCurrentAchievement(AchievementInfo(text: "Comfy Corners", subText: "Capture All Corners In One Match"))
                    AchievementLogger.instance.setCaptureCorners()
                }
            }
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
    
    private func updateScore() {
        var p1Score = 0
        var p2Score = 0
        
        for row in gameState.grid {
            for square in row {
                if square == .p1 { p1Score += 1 }
                else if square == .p2 { p2Score += 1 }
            }
        }
        
        gameState.playerScore1 = p1Score
        gameState.playerScore2 = p2Score
    }
    
    // Applies conversion for a row
    private func convertRow(row: Int, col: Int, to convertTo: GameGridSqaure) {
        let converting: GameGridSqaure
        
        if convertTo == .p1 { converting = .p2 }
        else { converting = .p1 }
        
        // Keep track of potential squares to convert (only apply the conversion if and when a square of the same colour is found)
        var squareColsToConvert = [Int]()
        var shouldConvert = false
        
        // Check from col to right of board
        for c in (col+1)..<gameState.gridSize {
            if gameState.grid[c][row] == converting {
                // Other player square found for potential conversion
                squareColsToConvert.append(c)
            } else if gameState.grid[c][row] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squareColsToConvert.removeAll()
                break;
            } else if gameState.grid[c][row] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        // Apply conversion to successful potential squares
        if shouldConvert {
            for square in squareColsToConvert {
                //                gameState.grid[square][row] = convertTo
                convertSquare(row: row, col: square, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squareColsToConvert.removeAll()
        
        
        // Check from left of board to col
        for c in (0..<col).reversed() {
            if gameState.grid[c][row] == converting {
                // Other player square found for potential conversion
                squareColsToConvert.append(c)
            } else if gameState.grid[c][row] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squareColsToConvert.removeAll()
                break;
            } else if gameState.grid[c][row] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        if shouldConvert {
            // Apply conversion to successful potential squares
            for square in squareColsToConvert {
                //                gameState.grid[square][row] = convertTo
                convertSquare(row: row, col: square, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
    }
    
    // Applies conversion for a column
    private func convertCol(row: Int, col: Int, to convertTo: GameGridSqaure) {
        let converting: GameGridSqaure
        
        if convertTo == .p1 { converting = .p2 }
        else { converting = .p1 }
        
        // Keep track of potential squares to convert (only apply the conversion if and when a square of the same colour is found)
        var squareRowsToConvert = [Int]()
        var shouldConvert = false
        
        // Check from row to bottom of board
        for r in (row+1)..<gameState.gridSize {
            if gameState.grid[col][r] == converting {
                // Other player square found for potential conversion
                squareRowsToConvert.append(r)
            } else if gameState.grid[col][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squareRowsToConvert.removeAll()
                break;
            } else if gameState.grid[col][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        // Apply conversion to successful potential squares
        if shouldConvert {
            for square in squareRowsToConvert {
                //                gameState.grid[col][square] = convertTo
                convertSquare(row: square, col: col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squareRowsToConvert.removeAll()
        
        
        // Check from top of board to row
        for r in (0..<row).reversed() {
            if gameState.grid[col][r] == converting {
                // Other player square found for potential conversion
                squareRowsToConvert.append(r)
            } else if gameState.grid[col][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squareRowsToConvert.removeAll()
                break;
            } else if gameState.grid[col][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        // Apply conversion to successful potential squares
        if shouldConvert {
            for square in squareRowsToConvert {
                //                gameState.grid[col][square] = convertTo
                convertSquare(row: square, col: col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
    }
    
    // Applies conversion for all four diagonal directions
    private func convertDiagonals(row: Int, col: Int, to convertTo: GameGridSqaure) {
        let converting: GameGridSqaure
        
        if convertTo == .p1 { converting = .p2 }
        else { converting = .p1 }
        
        // Keep track of potential squares to convert (only apply the conversion if and when a square of the same colour is found)
        var squaresToConvert = [(col: Int, row: Int)]()  // (col,row)
        var shouldConvert = false
        
        // Checking from (col,row) to right bottom of board
        for n in (1..<(gameState.gridSize - max(row, col))) {
            let c = col + n
            let r = row + n
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
                squaresToConvert.append((c,r))
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squaresToConvert.removeAll()
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        if shouldConvert {
            for square in squaresToConvert {
                //                gameState.grid[square.0][square.1] = convertTo
                convertSquare(row: square.row, col: square.col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squaresToConvert.removeAll()
        
        // From (col,row) to top left of board
        for n in 0..<(min(row, col)) {
            let c = col - n - 1
            let r = row - n - 1
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
                squaresToConvert.append((c,r))
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squaresToConvert.removeAll()
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        if shouldConvert {
            for square in squaresToConvert {
                //                gameState.grid[square.0][square.1] = convertTo
                convertSquare(row: square.row, col: square.col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squaresToConvert.removeAll()
        
        
        // From (col,row) to top right of board
        for n in 1..<(gameState.gridSize - max(col, (gameState.gridSize - 1 - row))) {
            let c = col + n
            let r = row - n
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
                squaresToConvert.append((c,r))
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squaresToConvert.removeAll()
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        if shouldConvert {
            for square in squaresToConvert {
                //                gameState.grid[square.0][square.1] = convertTo
                convertSquare(row: square.row, col: square.col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squaresToConvert.removeAll()
        
        
        // From (col,row) to bottom left of board
        for n in 1..<(gameState.gridSize - max(row, (gameState.gridSize - 1 - col))) {
            let c = col - n
            let r = row + n
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
                squaresToConvert.append((c,r))
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squaresToConvert.removeAll()
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        if shouldConvert {
            for square in squaresToConvert {
                //                gameState.grid[square.0][square.1] = convertTo
                convertSquare(row: square.row, col: square.col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squaresToConvert.removeAll()
    }
    
    // Checks if all squares have been filled, shows end game screen and saves statistics
    private func checkEndGame() {
        for row in gameState.grid {
            for square in row {
                if square == .canBePlacedOn || square == .empty { return }
            }
        }
        
        // Show end game screen
        print("GAME OVER!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation() {
                gameOver = true
                isPaused = true
            }
        }
    }
    
    private func convertSquare(row: Int, col: Int, convertTo: GameGridSqaure, flip: Bool, fade: Bool) {
        
        // Record stat
        if convertTo == .p1 { p1TilesConverted += 1 }
        else { p2TilesConverted += 1 }
        
        if fade {
            withAnimation {
                gameState.grid[col][row] = convertTo
            }
        } else {
            gameState.grid[col][row] = convertTo
        }
        if flip {
            withAnimation { rotated.append((row,col)) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                rotated.removeAll(where: { $0.row == row && $0.col == col })
            }
        }
    }
}

struct GameGridRemote: View, MessageDelegate {
    var isMessageDelegate = false
    @Binding var gameState: GameState
    @Binding var gameOver: Bool
    @Binding var isPaused: Bool
    @Binding var canPlay: Bool
    @Binding var clientType: ClientType
    @Binding var connectionService: ConnectionService
    @Binding var otherPlayQuit: Bool
    @Binding var otherPlayerRematch: Bool
    @Binding var p1TilesConverted: Int
    @Binding var p2TilesConverted: Int
    @Binding var currentAchievement: AchievementInfo?
    @Binding var showAchievementNotif: Bool
    
    @State var rotated = [(row: Int, col: Int)]()
    
    var body: some View {
        GeometryReader { g in
            Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                ForEach(0..<gameState.grid.count, id: \.self) { row in
                    GridRow {
                        ForEach(0..<gameState.grid.count, id: \.self) { col in
                            Rectangle()
                                .foregroundColor(getSquareColor(row: row, col: col))
                                .frame(width: g.size.width / CGFloat(gameState.gridSize) - 2, height: g.size.width / CGFloat(gameState.gridSize) - 2)
                                .cornerRadius(5)
                                .onTapGesture {
                                    if canPlay {
                                        requestMove(row: row, col: col)
                                    }
                                }
                                .rotation3DEffect(getRotation(col: col, row: row), axis: (0,1,0))
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear() {
            if isMessageDelegate {
                connectionService.messageDelegate = self
            }
        }
    }
    
    // MARK: - Message Processing
    func receivedMessage(msg: Message) {
        switch msg.key {
        case .pause:
            withAnimation {
                isPaused = msg.value == "true"
            }
        case .gameOver:
            withAnimation {
                gameOver = true
                isPaused = true
            }
        case .rematch:
            otherPlayerRematch = msg.value == "true"
        case .quit:
            otherPlayQuit = true
        case .requestMove:
            // Host receives from client, makes move on clients behalf and sends the move to the client to be handled on client end
            let move = parseMove(msg.value)
            handleAction(row: move.row, col: move.col, sendMove: true)
        case .makeMove:
            // Client player receives this message and makes move on its end
            let move = parseMove(msg.value)
            handleAction(row: move.row, col: move.col, sendMove: false)
        default: return
        }
    }
    
    func parseMove(_ moveStr: String ) -> (row: Int, col: Int) {
        let rowStr = moveStr[moveStr.index(moveStr.startIndex, offsetBy: 5)]
        let colStr = moveStr[moveStr.index(moveStr.startIndex, offsetBy: 3)]
        
        do {
            let row = try Int("\(rowStr)", strategy: IntegerParseStrategy(format: .number))
            let col = try Int("\(colStr)", strategy: IntegerParseStrategy(format: .number))
            return (row, col)
        } catch {
            print("Failed to parse move")
            return (0,0)
        }
    }
    
    // MARK: - Game logic functions
    private func getRotation(col: Int, row: Int) -> Angle {
        let filtered = rotated.filter( { $0.row == row && $0.col == col })
        if filtered.isEmpty { return .zero }
        else { return .degrees(180) }
    }
    
    private func getSquareColor(row: Int, col: Int) -> Color {
        switch gameState.grid[col][row] {
        case .empty: return Color(uiColor: .systemGray5)
        case .canBePlacedOn: return Color(uiColor: .systemGray3)
        case .p1: return clientType == .host ? Color(gameState.player1.colour):Color(gameState.player2.colour)
        case .p2: return clientType == .host ? Color(gameState.player2.colour):Color(gameState.player1.colour)
        }
    }
    
    private func requestMove(row: Int, col: Int) {
        // If current player is the host, make move and send move
        // if current player is the client, request a move to be made
        if clientType == .host { handleAction(row: row, col: col, sendMove: true) }
        else { connectionService.sendMessage(msg: Message(key: .requestMove, player: 2, moveToRow: row, moveToCol: col)) }
    }
    
    private func handleAction(row: Int, col: Int, sendMove: Bool) {
        
        if gameOver { return }
        
        if gameState.grid[col][row] == .canBePlacedOn {
            let convertTo: GameGridSqaure
            if gameState.currentTurn.number == 1 { convertTo = .p1 } else { convertTo = .p2 }
            
            
            // Convert current square
            //            gameState.grid[col][row] = convertTo
            convertSquare(row: row, col: col, convertTo: convertTo, flip: false, fade: true)
            if (gameState.currentTurn.number == 1 && clientType == .host) ||
               (gameState.currentTurn.number == 2 && clientType == .client) {
                Utils.playSound(withVolume: 0.1, url: Utils.tilePlacedURL)
//                UISelectionFeedbackGenerator().selectionChanged()
                Utils.playLightHaptic()
            }
            
            /*
             send move to other player (if player is host). Other player will compute the outcome for the board on its end too
             */
            if sendMove {
                // send
                connectionService.sendMessage(msg: Message(key: .makeMove, player: gameState.currentTurn.number, moveToRow: row, moveToCol: col))
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                // Convert connections
                convertCol(row: row, col: col, to: convertTo)
                convertRow(row: row, col: col, to: convertTo)
                convertDiagonals(row: row, col: col, to: convertTo)
                
                updateScore()
                updateAchievements()
            }
            
            
            // Update the "can be placed on" squares
            // Create a 3x3 grid around the tapped square, convert all empty sqaures
            for c in (col-1)...(col+1) {
                for r in (row-1)...(row+1) {
                    if c < 0 || c >= gameState.gridSize || r < 0 || r >= gameState.gridSize { continue; }
                    if gameState.grid[c][r] == .empty { convertSquare(row: r, col: c, convertTo: .canBePlacedOn, flip: false, fade: true) }
                }
            }
            
            
            // Update player tiles information
            if convertTo == .p1 {
                gameState.playerTiles1 -= 1
            } else {
                gameState.playerTiles2 -= 1
            }
            
            
            // Next player's turn
            gameState.toggleTurn()
            canPlay.toggle()
            
            
            // Check for end of game
            checkEndGame()
            
            if gameOver { return }
        }
        
    }
    
    private func updateScore() {
        var p1Score = 0
        var p2Score = 0
        
        for row in gameState.grid {
            for square in row {
                if square == .p1 { p1Score += 1 }
                else if square == .p2 { p2Score += 1 }
            }
        }
        
        gameState.playerScore1 = p1Score
        gameState.playerScore2 = p2Score
    }
    
    // Applies conversion for a row
    private func convertRow(row: Int, col: Int, to convertTo: GameGridSqaure) {
        let converting: GameGridSqaure
        
        if convertTo == .p1 { converting = .p2 }
        else { converting = .p1 }
        
        // Keep track of potential squares to convert (only apply the conversion if and when a square of the same colour is found)
        var squareColsToConvert = [Int]()
        var shouldConvert = false
        
        // Check from col to right of board
        for c in (col+1)..<gameState.gridSize {
            if gameState.grid[c][row] == converting {
                // Other player square found for potential conversion
                squareColsToConvert.append(c)
            } else if gameState.grid[c][row] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squareColsToConvert.removeAll()
                break;
            } else if gameState.grid[c][row] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        // Apply conversion to successful potential squares
        if shouldConvert {
            for square in squareColsToConvert {
                //                gameState.grid[square][row] = convertTo
                convertSquare(row: row, col: square, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squareColsToConvert.removeAll()
        
        
        // Check from left of board to col
        for c in (0..<col).reversed() {
            if gameState.grid[c][row] == converting {
                // Other player square found for potential conversion
                squareColsToConvert.append(c)
            } else if gameState.grid[c][row] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squareColsToConvert.removeAll()
                break;
            } else if gameState.grid[c][row] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        if shouldConvert {
            // Apply conversion to successful potential squares
            for square in squareColsToConvert {
                //                gameState.grid[square][row] = convertTo
                convertSquare(row: row, col: square, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
    }
    
    // Applies conversion for a column
    private func convertCol(row: Int, col: Int, to convertTo: GameGridSqaure) {
        let converting: GameGridSqaure
        
        if convertTo == .p1 { converting = .p2 }
        else { converting = .p1 }
        
        // Keep track of potential squares to convert (only apply the conversion if and when a square of the same colour is found)
        var squareRowsToConvert = [Int]()
        var shouldConvert = false
        
        // Check from row to bottom of board
        for r in (row+1)..<gameState.gridSize {
            if gameState.grid[col][r] == converting {
                // Other player square found for potential conversion
                squareRowsToConvert.append(r)
            } else if gameState.grid[col][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squareRowsToConvert.removeAll()
                break;
            } else if gameState.grid[col][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        // Apply conversion to successful potential squares
        if shouldConvert {
            for square in squareRowsToConvert {
                //                gameState.grid[col][square] = convertTo
                convertSquare(row: square, col: col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squareRowsToConvert.removeAll()
        
        
        // Check from top of board to row
        for r in (0..<row).reversed() {
            if gameState.grid[col][r] == converting {
                // Other player square found for potential conversion
                squareRowsToConvert.append(r)
            } else if gameState.grid[col][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squareRowsToConvert.removeAll()
                break;
            } else if gameState.grid[col][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        // Apply conversion to successful potential squares
        if shouldConvert {
            for square in squareRowsToConvert {
                //                gameState.grid[col][square] = convertTo
                convertSquare(row: square, col: col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
    }
    
    // Applies conversion for all four diagonal directions
    private func convertDiagonals(row: Int, col: Int, to convertTo: GameGridSqaure) {
        let converting: GameGridSqaure
        
        if convertTo == .p1 { converting = .p2 }
        else { converting = .p1 }
        
        // Keep track of potential squares to convert (only apply the conversion if and when a square of the same colour is found)
        var squaresToConvert = [(col: Int, row: Int)]()  // (col,row)
        var shouldConvert = false
        
        // Checking from (col,row) to right bottom of board
        for n in (1..<(gameState.gridSize - max(row, col))) {
            let c = col + n
            let r = row + n
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
                squaresToConvert.append((c,r))
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squaresToConvert.removeAll()
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        if shouldConvert {
            for square in squaresToConvert {
                //                gameState.grid[square.0][square.1] = convertTo
                convertSquare(row: square.row, col: square.col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squaresToConvert.removeAll()
        
        // From (col,row) to top left of board
        for n in 0..<(min(row, col)) {
            let c = col - n - 1
            let r = row - n - 1
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
                squaresToConvert.append((c,r))
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squaresToConvert.removeAll()
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        if shouldConvert {
            for square in squaresToConvert {
                //                gameState.grid[square.0][square.1] = convertTo
                convertSquare(row: square.row, col: square.col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squaresToConvert.removeAll()
        
        
        // From (col,row) to top right of board
        for n in 1..<(gameState.gridSize - max(col, (gameState.gridSize - 1 - row))) {
            let c = col + n
            let r = row - n
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
                squaresToConvert.append((c,r))
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squaresToConvert.removeAll()
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        if shouldConvert {
            for square in squaresToConvert {
                //                gameState.grid[square.0][square.1] = convertTo
                convertSquare(row: square.row, col: square.col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squaresToConvert.removeAll()
        
        
        // From (col,row) to bottom left of board
        for n in 1..<(gameState.gridSize - max(row, (gameState.gridSize - 1 - col))) {
            let c = col - n
            let r = row + n
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
                squaresToConvert.append((c,r))
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
                squaresToConvert.removeAll()
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                shouldConvert = true
                break;
            }
        }
        
        if shouldConvert {
            for square in squaresToConvert {
                //                gameState.grid[square.0][square.1] = convertTo
                convertSquare(row: square.row, col: square.col, convertTo: convertTo, flip: true, fade: true)
            }
            shouldConvert = false
        }
        
        squaresToConvert.removeAll()
        
    }
    
    // Checks if all squares have been filled, shows end game screen and saves statistics
    private func checkEndGame() {
        for row in gameState.grid {
            for square in row {
                if square == .canBePlacedOn || square == .empty { return }
            }
        }
        
        // Show end game screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation() {
                gameOver = true
                isPaused = true
            }
        }
        
        // TODO: save statistics
    }
    
    private func convertSquare(row: Int, col: Int, convertTo: GameGridSqaure, flip: Bool, fade: Bool) {
        if fade {
            withAnimation {
                gameState.grid[col][row] = convertTo
            }
        } else {
            gameState.grid[col][row] = convertTo
        }
        if flip {
            // Record stat
            if convertTo == .p1 { p1TilesConverted += 1 }
            else { p2TilesConverted += 1 }
            
            withAnimation { rotated.append((row,col)) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                rotated.removeAll(where: { $0.row == row && $0.col == col })
            }
        }
    }
    
    private func updateAchievements() {
        if !AchievementLogger.instance.getCaptureCorners() {
            let cornerCheck: GameGridSqaure?
            if clientType == .host { cornerCheck = .p1 }
            else { cornerCheck = .p2 }
            
            if let cornerCheck {
                if (gameState.grid[0][0] == cornerCheck &&
                    gameState.grid[0][gameState.gridSize-1] == cornerCheck &&
                    gameState.grid[gameState.gridSize-1][0] == cornerCheck &&
                    gameState.grid[gameState.gridSize-1][gameState.gridSize-1] == cornerCheck) {
                    setCurrentAchievement(AchievementInfo(text: "Comfy Corners", subText: "Capture All Corners In One Match"))
                    AchievementLogger.instance.setCaptureCorners()
                }
            }
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
