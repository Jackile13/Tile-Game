//
//  AIMediumStrategy.swift
//  Tile Game
//
//  Created by Jack Allie on 11/1/2023.
//

import Foundation

/*
 Medium strategy takes into account all possible squares and picks the one with the greatest number of opponent squares adjacent
 This gives are higher chance of scoring points
 */
struct AIMediumStrategy: AIStrategy {
    func makeMove(gameState: GameState) -> Move {
        var potentialSquares = [(move: Move, tileCount: Int)]()
        
        for col in 0..<gameState.gridSize {
            for row in 0..<gameState.gridSize {
                if gameState.grid[col][row] == .canBePlacedOn {
                    let move = Move(row: row, col: col)
                    potentialSquares.append((move, getOpponentSquareCount(for: move, state: gameState)))
                }
            }
        }
        
        if potentialSquares.isEmpty { return Move(row: 0, col: 0) }
        
        potentialSquares.sort { move1, move2 in
            return move1.tileCount > move2.tileCount
        }
        
        let highestVal = potentialSquares.first!.tileCount
        
        potentialSquares = potentialSquares.filter({ $0.tileCount == highestVal })
        potentialSquares.shuffle()
        
        
        return potentialSquares.first!.move
    }
    
    private func getOpponentSquareCount(for move: Move, state: GameState) -> Int {
        var count = 0
        let enemySquare: GameGridSqaure
        
        if (state.currentTurn.number == 1) { enemySquare = .p2 }
        else { enemySquare = .p1}
        
        // Check 3x3 grid around target and count opponent tiles
        for c in (move.col-1)...(move.col+1) {
            if c < 0 || c >= state.gridSize { continue }
            for r in (move.row-1)...(move.row+1) {
                if r < 0 || r >= state.gridSize { continue }
                if state.grid[c][r] == enemySquare { count += 1 }
            }
        }
        
        return count
    }
    
}
