//
//  ConnectionService.swift
//  Tile Game
//
//  Created by Jack Allie on 12/1/2023.
//

import Foundation
import MultipeerConnectivity

protocol ConnectionServiceClientDelegate {
    func foundHost(_ peerID: MCPeerID)
    func lostHost(_ peerID: MCPeerID)
}

protocol ConnectionServiceHostDelegate {
    func receivedConnectionRequest(from peerID: MCPeerID, invitationHandler: @escaping (Bool, MCSession?) -> Void, session: MCSession)
}

protocol ConnectionServiceDelegate {
    func connecting(to peer: MCPeerID)
    func connected(to peer: MCPeerID)
}

protocol MessageDelegate {
    func receivedMessage(msg: Message)
}

class ConnectionService: NSObject {
    private let peerID: MCPeerID = MCPeerID(displayName: SettingsData.instance.getPlayerName())
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private let serviceType = "qc-tilegame"
    public var hostDelegate: ConnectionServiceHostDelegate?
    public var clientDelegate: ConnectionServiceClientDelegate?
    public var delegate: ConnectionServiceDelegate?
    public var messageDelegate: MessageDelegate?
    lazy var session: MCSession = {
        let session = MCSession(peer: peerID)
        session.delegate = self
        return session
    }()
    
    private static var connectionService: ConnectionService?
    
    public static func getConnectionService() -> ConnectionService {
        if self.connectionService == nil { return ConnectionService() }
        else { return self.connectionService! }
    }
    
    public var connectedPeers = [MCPeerID]()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
    }
    
    deinit {
        self.stopHosting()
        self.stopBrowsing()
    }
    
    /**
     Start being available to host a game
     */
    public func startHosting() {
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    /**
     Start looking for games
     */
    public func startBrowsing() {
        serviceBrowser.startBrowsingForPeers()
    }
    
    /**
     Stops looking for other devices to connect to
     */
    public func stopBrowsing() {
        serviceBrowser.stopBrowsingForPeers()
    }
    
    /**
     Stops advertising that this device can host a game
     */
    public func stopHosting() {
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    /**
     Sends a request to join a session of the given peer
     */
    public func sendJoinRequest(peer: MCPeerID) {
        serviceBrowser.invitePeer(peer, to: self.session, withContext: nil, timeout: 60)
    }
    
    public func sendMessage(msg: Message) {
        print("Sending message to peers: \(connectedPeers)")
        do {
            let data = try JSONEncoder().encode(msg)
            try session.send(data, toPeers: connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func receiveMessage(msg: Message) {
        messageDelegate?.receivedMessage(msg: msg)
    }
}

extension ConnectionService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // update list
        print("Browser found peer")
        if let clientDelegate { clientDelegate.foundHost(peerID) } else { print("No client delegate") }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // update list
        print("Browser lost peer")
        if let clientDelegate { clientDelegate.lostHost(peerID) } else { print("No client delegate ") }
    }
    
}

extension ConnectionService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // response to connection
        if advertiser.serviceType == serviceType {
            hostDelegate?.receivedConnectionRequest(from: peerID, invitationHandler: invitationHandler, session: session)
        }
    }
    
}

extension ConnectionService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
            print("All connected: \(session.connectedPeers)")
            connectedPeers.append(peerID)
            if let delegate {
                delegate.connected(to: peerID)
            } else {
                print("Could not find delegate")
            }
//            delegate?.connected(to: peerID)
        case .connecting:
            print("Connecting: \(peerID.displayName)")
            if let delegate {
                delegate.connecting(to: peerID)
            } else {
                print("Could not find delegate")
            }
//            delegate?.connecting(to: peerID)
        case .notConnected:
            print("Not connected: \(peerID.displayName)")
//            connectedPeers.removeAll(where: { $0 == peerID })
            print("PeerIDS: \(connectedPeers)")
            
        // This is used for any unknown future cases that don't currently exist but may in future updates
        @unknown default:
            print("Unknown state recieved: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let msg: Message = try JSONDecoder().decode(Message.self, from: data)
            receiveMessage(msg: msg)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // empty
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // empty
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // empty
    }
    
    
}
