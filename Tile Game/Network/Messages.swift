//
//  Messages.swift
//  Tile Game
//
//  Created by Jack Allie on 14/1/2023.
//

import Foundation

//enum MessageType: Codable {
//    case hello
//    case colourChange
//    case ready
//    case startGame
//    case requestMove
//    case makeMove
//    case gameOver
//    case pause
//    case quit
//    case rematch
//
//    func caseToType() -> Message.Type {
//        switch self {
//        case .hello: return HelloMessage.self
//        case .colourChange: return ColourChangeMessage.self
//        default: return Message.self
//        }
//    }
//}

enum MessageKey: Codable {
    case hello
    case colourChange
    case gridSizeChange
    case ready
    case startGame
    case requestMove
    case makeMove
    case gameOver
    case pause
    case quit
    case rematch
}

// MARK: - Message
/*
 key            | value
 ------------------------------------
 hello         | Name of player
 colourChange  | Colour changing to
 ready         | true or false - Inidcation of ready to start game
 startGame     | No value - Host uses to tell peer the game should start
 requestMove   | The move to make - Made by peer to ask the host to make a move on their behalf
 makeMove      | The move made - Made by host to tell peer a move has been made to update their board
 gameOver      | Winner
 pause         | true (game being pause) or false
 quit          | No value - disconnect and return to main menu
 rematch       | No value - go to game setup
 
 Move format:
 <player_number>-(<col>,<row>)
 e.g. player 1 plays a tile at column 3 row 5: 1-(3,5)
 */
class Message: Codable {
    let key: MessageKey
    let value: String
    
    init(key: MessageKey, value: String) {
        self.key = key
        self.value = value
    }
    
    init(key: MessageKey, value: Bool) {
        self.key = key
        self.value = value ? "true":"false"
    }
    
    init(key: MessageKey, value: Float) {
        self.key = key
        self.value = "\(value)"
    }
    
    init(key: MessageKey, player: Int, moveToRow: Int, moveToCol: Int) {
        self.key = key
        self.value = "\(player)-(\(moveToCol),\(moveToRow)"
    }
}


//// MARK: - Setup Messages
//class HelloMessage: Message {
//    let username: String
//
//    init(username: String) {
//        self.username = username
//        super.init(msgType: .hello)
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}
//
//class ColourChangeMessage: Message {
//    let colourName: String
//
//    init(colourName: String) {
//        self.colourName = colourName
//        super.init(msgType: .colourChange)
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}
//
//class readyMessage: Message {
//    init() {
//        super.init(msgType: .ready)
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}
