//
//  AIHardStrategy.swift
//  Tile Game
//
//  Created by Jack Allie on 11/1/2023.
//

import Foundation

struct AIHardStrategy: AIStrategy {
    private var gameState: GameState?
    private var gridScores: [[Float]] = []
    
    enum GameStage {
        case early
        case mid
        case late
    }
    
    mutating func makeMove(gameState: GameState) -> Move {
        self.gameState = gameState
        
        initGridScores()
        applyPositionModifiers()
        applyConversionModifiers()
        
        return getAHighestScoringMove()
    }
    
    private func getAHighestScoringMove() -> Move {
        guard let gameState = gameState else { return Move(row: 0, col: 0) }
        
        var highestScore: Float = 0
        
        // Get highest value
        for col in 0..<gameState.gridSize {
            for row in 0..<gameState.gridSize {
                if gridScores[col][row] > highestScore { highestScore = gridScores[col][row] }
            }
        }
        
        var highestSquares = [Move]()
        
        // Get all squares with highest value
        for col in 0..<gameState.gridSize {
            for row in 0..<gameState.gridSize {
                if gridScores[col][row] == highestScore { highestSquares.append(Move(row: row, col: col)) }
            }
        }
        
        if !highestSquares.isEmpty {
            return highestSquares.randomElement()!
        }
        
        print("Failed to get move")
        
        return Move(row: 0, col: 0)
    }
    
    private mutating func initGridScores() {
        guard let gameState = gameState else { return }
        gridScores = []
        
        // Initialise to correct size with empty values
        for _ in 0..<gameState.gridSize {
            gridScores.append(Array(repeating: 0.0, count: gameState.gridSize))
        }
        
        // Fill in with squares that can be placed on to have a score of 10
        for row in 0..<gameState.gridSize {
            for col in 0..<gameState.gridSize {
                if gameState.grid[col][row] == .canBePlacedOn {
                    gridScores[col][row] = 10.0
                }
            }
        }
    }
    
    // Applies modifiers to the gridScores based on potential conversions
    private mutating func applyConversionModifiers() {
        guard let gameState = gameState else { return }
        
        let conversionModifier: Float
        
        switch getGameStage() {
        case .early: conversionModifier = 0.5
        case .mid: conversionModifier = 0.75
        case .late: conversionModifier = 1.0
        }
        
        for col in 0..<gameState.gridSize {
            for row in 0..<gameState.gridSize {
                gridScores[col][row] += conversionModifier * Float(countConversions(col, row))
            }
        }
    }
    
    private func countConversions(_ col: Int, _ row: Int) -> Int {
        guard let gameState = gameState else { return 0 }
        
        if gameState.grid[col][row] != .canBePlacedOn { return 0 }
        
        return countRowConversions(col,row) + countColumnConversions(col,row) + countDiagonalConversions(col,row)
    }
    
    private func countRowConversions(_ col: Int, _ row: Int) -> Int {
        guard let gameState = gameState else { return 0 }
        
        var finalNumConversions = 0
        let converting: GameGridSqaure
        let convertTo: GameGridSqaure
        
        if gameState.currentTurn.number == 1 {
            print("Hard AI is player 1, checking how many potential conversions from player 2 to player 1")
            converting = .p2
            convertTo = .p1
        } else {
            print("Hard AI is player 2, checking how many potential conversions from player 1 to player 2")
            converting = .p1
            convertTo = .p2
        }
        
        var numConversions = 0
        var canConvert = false
        
        // Check from col to right of board
        for c in (col+1)..<gameState.gridSize {
            if gameState.grid[c][row] == converting {
                // Other player square found for potential conversion
//                squareColsToConvert.append(c)
                numConversions += 1
            } else if gameState.grid[c][row] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
//                squareColsToConvert.removeAll()
                numConversions = 0
                break;
            } else if gameState.grid[c][row] == convertTo {
                // Found own square, convert all squares inbetween
                canConvert = true
                break;
            }
        }
        
        // Apply conversion to successful potential squares
        if canConvert {
            finalNumConversions += numConversions
            canConvert = false
        }
        
        numConversions = 0
        
        
        // Check from left of board to col
        for c in (0..<col).reversed() {
            if gameState.grid[c][row] == converting {
                // Other player square found for potential conversion
//                squareColsToConvert.append(c)
                numConversions += 1
            } else if gameState.grid[c][row] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
//                squareColsToConvert.removeAll()
                numConversions = 0
                break;
            } else if gameState.grid[c][row] == convertTo {
                // Found own square, convert all squares inbetween
                canConvert = true
                break;
            }
        }
        
        // Apply conversion to successful potential squares
        if canConvert {
            finalNumConversions += numConversions
            canConvert = false
        }
        
        return finalNumConversions
    }
    
    private func countColumnConversions(_ col: Int, _ row: Int) -> Int {
        guard let gameState = gameState else { return 0 }
        
        var finalNumConversions = 0
        let converting: GameGridSqaure
        let convertTo: GameGridSqaure
        
        if gameState.currentTurn.number == 1 {
            print("Hard AI is player 1, checking how many potential conversions from player 2 to player 1")
            converting = .p2
            convertTo = .p1
        } else {
            print("Hard AI is player 2, checking how many potential conversions from player 1 to player 2")
            converting = .p1
            convertTo = .p2
        }
        
        var numConversions = 0
        var canConvert = false
        
        // Check from row to bottom of board
        for r in (row+1)..<gameState.gridSize {
            if gameState.grid[col][r] == converting {
                // Other player square found for potential conversion
//                squareColsToConvert.append(c)
                numConversions += 1
            } else if gameState.grid[col][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
//                squareColsToConvert.removeAll()
                numConversions = 0
                break;
            } else if gameState.grid[col][r] == convertTo {
                // Found own square, convert all squares inbetween
                canConvert = true
                break;
            }
        }
        
        // Apply conversion to successful potential squares
        if canConvert {
            finalNumConversions += numConversions
            canConvert = false
        }
        
        numConversions = 0
        
        // Check from row to top of board
        for r in (0..<row).reversed() {
            if gameState.grid[col][r] == converting {
                // Other player square found for potential conversion
//                squareColsToConvert.append(c)
                numConversions += 1
            } else if gameState.grid[col][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
//                squareColsToConvert.removeAll()
                numConversions = 0
                break;
            } else if gameState.grid[col][r] == convertTo {
                // Found own square, convert all squares inbetween
                canConvert = true
                break;
            }
        }
        
        // Apply conversion to successful potential squares
        if canConvert {
            finalNumConversions += numConversions
            canConvert = false
        }
        
        return finalNumConversions
    }
    
    private func countDiagonalConversions(_ col: Int, _ row: Int) -> Int {
        guard let gameState = gameState else { return 0 }
        
        let converting: GameGridSqaure
        let convertTo: GameGridSqaure
        var finalNumConversions = 0
        
        if gameState.currentTurn.number == 1 {
            converting = .p2
            convertTo = .p1
        }
        else {
            converting = .p1
            convertTo = .p2
        }
        
        // Keep track of potential squares to convert (only apply the conversion if and when a square of the same colour is found)
//        var squaresToConvert = [(col: Int, row: Int)]()  // (col,row)
//        var shouldConvert = false
        var numConversions = 0
        var canConvert = false
        
        // Checking from (col,row) to right bottom of board
        for n in (1..<(gameState.gridSize - max(row, col))) {
            let c = col + n
            let r = row + n
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
//                squaresToConvert.append((c,r))
                numConversions += 1
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
//                squaresToConvert.removeAll()
                numConversions = 0
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                canConvert = true
                break;
            }
        }
        
        if canConvert {
            finalNumConversions += numConversions
            canConvert = false
        }
        
//        squaresToConvert.removeAll()
        numConversions = 0
        
        // From (col,row) to top left of board
        for n in 0..<(min(row, col)) {
            let c = col - n - 1
            let r = row - n - 1
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
//                squaresToConvert.append((c,r))
                numConversions += 1
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
//                squaresToConvert.removeAll()
                numConversions = 0
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                canConvert = true
                break;
            }
        }
        
        if canConvert {
            finalNumConversions += numConversions
            canConvert = false
        }
        
//        squaresToConvert.removeAll()
        numConversions = 0
        
        
        // From (col,row) to top right of board
        for n in 1..<(gameState.gridSize - max(col, (gameState.gridSize - 1 - row))) {
            let c = col + n
            let r = row - n
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
//                squaresToConvert.append((c,r))
                numConversions += 1
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
//                squaresToConvert.removeAll()
                numConversions = 0
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                canConvert = true
                break;
            }
        }
        
        if canConvert {
            finalNumConversions += numConversions
            canConvert = false
        }
        
//        squaresToConvert.removeAll()
        numConversions = 0
        
        
        // From (col,row) to bottom left of board
        for n in 1..<(gameState.gridSize - max(row, (gameState.gridSize - 1 - col))) {
            let c = col - n
            let r = row + n
            if gameState.grid[c][r] == converting {
                // Other player square found for potential conversion
//                squaresToConvert.append((c,r))
                numConversions += 1
            } else if gameState.grid[c][r] == .canBePlacedOn {
                // Found an unclaimed square, no conversion possible
//                squaresToConvert.removeAll()
                numConversions = 0
                break;
            } else if gameState.grid[c][r] == convertTo {
                // Found own square, convert all squares inbetween
                canConvert = true
                break;
            }
        }
        
        if canConvert {
            finalNumConversions += numConversions
            canConvert = false
        }
        
        return finalNumConversions
    }
    
    // Applies modifiers to the gridScores based on their position
    private mutating func applyPositionModifiers() {
        guard let gameState = gameState else { return }
        let gameStage = getGameStage()
        
        var cornerModifier: Float = 0
        var midEdgeModifier: Float = 0
        let nearCornerModifier: Float = -1
        var nearCenterModifier: Float = 0
        
        // Early game
        if gameStage == .early {
            cornerModifier = 4
            midEdgeModifier = 2
        }
        
        // Mid game
        if gameStage == .mid {
            cornerModifier = 3
            midEdgeModifier = 2
            nearCenterModifier = 1
        }
        
        // Late game
        if gameStage == .late {
            cornerModifier = 1
            midEdgeModifier = 1
            nearCenterModifier = 1
        }
        
        for col in 0..<gameState.gridSize {
            for row in 0..<gameState.gridSize {
                if isCorner(col,row) { gridScores[col][row] += cornerModifier }
                if isNearCorner(col,row) { gridScores[col][row] += nearCornerModifier }
                if isNearCenter(col,row) { gridScores[col][row] += nearCenterModifier }
                if isMidEdge(col,row) { gridScores[col][row] += midEdgeModifier }
            }
        }
    }
    
    // Checks if the square is a corner square
    private func isCorner(_ col: Int, _ row: Int) -> Bool {
        guard let gameState = gameState else { return false }
        let edge = gameState.gridSize - 1
        
        if (col == 0 && row == 0 ||
            col == 0 && row == edge ||
            col == edge && row == 0 ||
            col == edge && row == edge) {
            return true
        }
        
        return false
    }
    
    // Checks if the square is adjacent to a corner
    private func isNearCorner(_ col: Int, _ row: Int) -> Bool {
        // For each adjacent square, return true if it is a corner
        for adjCol in (col-1)...(col+1) {
            for adjRow in (row-1)...(row+1) {
                if isCorner(adjCol, adjRow) { return true }
            }
        }
        
        return false
    }
    
    // Checks if the square is near the center (dependant on grid size)
    private func isNearCenter(_ col: Int, _ row: Int) -> Bool {
        guard let gameState = gameState else { return false }
        let centerSize: Int
        let centerUpper = gameState.gridSize / 2
        let centerLower = centerUpper - 1
        
        if gameState.gridSize == 6 { centerSize = 1 }
        else if gameState.gridSize == 8 { centerSize = 1 }
        else if gameState.gridSize == 10 { centerSize = 2 }
        else { return false }
        
        if (col >= (centerLower - centerSize) && col <= (centerUpper + centerSize) &&
            row >= (centerLower - centerSize) && row <= (centerUpper + centerSize)) {
            return true
        }
        
        return false
    }
    
    private func isMidEdge(_ col: Int, _ row: Int) -> Bool {
        guard let gameState = gameState else { return false }
        let centerSize: Int
        let centerUpper = gameState.gridSize / 2
        let centerLower = centerUpper - 1
        
        if gameState.gridSize == 6 { centerSize = 0 }
        else if gameState.gridSize == 8 { centerSize = 1 }
        else if gameState.gridSize == 10 { centerSize = 2 }
        else { return false }
        
        if (col >= (centerLower - centerSize) && col <= (centerUpper + centerSize) &&
            row >= (centerLower - centerSize) && row <= (centerUpper + centerSize)) {
            return true
        }
        
        return false
    }
    
    // Gets the stage of the game based on tiles left to place
    private func getGameStage() -> GameStage {
        guard let gameState = gameState else { return .mid }
        
        let tilesRemaining = gameState.playerTiles1 + gameState.playerTiles2
        
        if Double(tilesRemaining) > 0.7 * Double(gameState.gridSize) { return .early }
        else if Double(tilesRemaining) > 0.3 * Double(gameState.gridSize) { return .mid }
        else { return .late }
    }
}
