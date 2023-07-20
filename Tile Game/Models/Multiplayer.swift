//
//  Multiplayer.swift
//  Tile Game
//
//  Created by Jack Allie on 12/1/2023.
//

import Foundation
import MultipeerConnectivity

enum ClientType: Hashable {
    case host
    case client
}

struct PotentialConnection: Equatable {
    
    static func == (lhs: PotentialConnection, rhs: PotentialConnection) -> Bool {
        return lhs.peerID == rhs.peerID &&
               lhs.session == rhs.session
    }
    
    let peerID: MCPeerID
    let session: MCSession
    let handler: (Bool, MCSession?) -> Void
}
