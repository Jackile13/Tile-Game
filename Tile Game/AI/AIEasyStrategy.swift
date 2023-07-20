//
//  AIEasyStrategy.swift
//  Tile Game
//
//  Created by Jack Allie on 11/1/2023.
//

import Foundation

struct AIEasyStrategy: AIStrategy {
    
    /*
     Simple strategy: randomly choose a square to place a tile
     */
    func makeMove(gameState: GameState) -> Move {
        var potentialSquares = [Move]()
        
        for col in 0..<gameState.gridSize {
            for row in 0..<gameState.gridSize {
                if gameState.grid[col][row] == .canBePlacedOn {
                    potentialSquares.append(Move(row: row, col: col))
                }
            }
        }
        
        if potentialSquares.isEmpty {
            return Move(row: 0, col: 0)
        }
        let move = potentialSquares.randomElement()!
        return move
    }
}
