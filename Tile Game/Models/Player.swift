//
//  Player.swift
//  Tile Game
//
//  Created by Jack Allie on 8/1/2023.
//

import Foundation
import SwiftUI

let colours: [Color] = [Color("Red"),    Color("Pink"),   Color("Light Blue"),
                        Color("Purple"), Color("Green"),  Color("Dark Green"),
                        Color("Yellow"), Color("Orange"), Color("Dark Blue")]
let colourStrings: [String] = ["Red", "Pink", "Light Blue", "Purple", "Green", "Dark Green", "Yellow", "Orange", "Dark Blue"]


enum PlayerType: Equatable, Codable, Hashable {
    case human
    case AI(DifficultyType)
    
    func toString() -> String {
        switch self {
        case .human: return "Human"
        case .AI(.easy): return "AI (Easy)"
        case .AI(.medium): return "AI (Medium)"
        case .AI(.hard): return "AI (Hard)"
        }
    }
}

enum DifficultyType: Codable {
    case easy
    case medium
    case hard
}

struct Player {
    var name: String
    let number: Int
    var type: PlayerType
    var colour: String
    var AIStrategy: (any AIStrategy)?
    
    init(name: String, number: Int, type: PlayerType, colour: String) {
        self.name = name
        self.number = number
        self.type = type
        self.colour = colour
        self.AIStrategy = nil
    }
    
    init(name: String, number: Int, type: PlayerType, colour: String, AIStrategy: (any AIStrategy)?) {
        self.name = name
        self.number = number
        self.type = type
        self.colour = colour
        self.AIStrategy = AIStrategy
    }
}
