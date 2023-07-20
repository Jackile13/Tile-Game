//
//  Game.swift
//  Tile Game
//
//  Created by Jack Allie on 9/1/2023.
//

import Foundation

//struct Game {
//    let size: Int
//    var p1Score: Int
//    var p2Score: Int
//}

enum GameGridSqaure {
    case p1
    case p2
    case empty
    case canBePlacedOn
}

struct GameState {
    var gridSize: Int
    var playerScore1: Int = 2
    var playerScore2: Int = 2
    var playerTiles1: Int
    var playerTiles2: Int
    var grid: [[GameGridSqaure]] = []
    var currentTurn: Player
    let player1: Player
    let player2: Player
    
    init(gridSize: Int, player1: Player, player2: Player) {
        let totalSquares = gridSize * gridSize
        self.playerTiles1 = totalSquares / 2 - 2
        self.playerTiles2 = totalSquares / 2 - 2
        self.gridSize = gridSize
        self.player1 = player1
        self.player2 = player2
        self.currentTurn = player1
    }
    
    public mutating func toggleTurn() {
        if currentTurn.number == player1.number { currentTurn = player2 }
        else { currentTurn = player1 }
    }
}
