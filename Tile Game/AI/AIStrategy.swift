//
//  AIStrategy.swift
//  Tile Game
//
//  Created by Jack Allie on 11/1/2023.
//

import Foundation

protocol AIStrategy {
    mutating func makeMove(gameState: GameState) -> Move
}

struct Move {
    let row: Int
    let col: Int
}
