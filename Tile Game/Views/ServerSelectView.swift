//
//  ServerSelectView.swift
//  Tile Game
//
//  Created by Jack Allie on 8/1/2023.
//
// Shows list of games posted on local network to choose from
// Shows a button to host a game
// When hosting a game, alert popups up to choose game name

import SwiftUI
import MultipeerConnectivity

struct ServerSelectView: View, ConnectionServiceDelegate {
    
    @State var connectionService = ConnectionService()
    
    @Binding var navigation: [Int]
    
    @State var showGameSetup = false
    @State var clientType = ClientType.client
    
    var body: some View {
        ZStack {
            VStack {
//                Button("test") {
//                    connectionService.stopHosting()
//                    connectionService.stopBrowsing()
//                    showGameSetup = true
//                }
                Picker("", selection: $clientType.animation()) {
                    Text("Join").tag(ClientType.client)
                    Text("Host").tag(ClientType.host)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Spacer()
                
                if clientType == .client {
                    JoinConnectionView(connectionService: $connectionService)
                        .transition(.move(edge: .trailing))
                        .onAppear() {
                            connectionService.startBrowsing()
                        }
                        .onDisappear() {
                            connectionService.stopBrowsing()
                        }
                } else {
                    HostConnectionView(connectionService: $connectionService)
                        .transition(.move(edge: .leading))
                        .onAppear() {
                            connectionService.startHosting()
                        }
                        .onDisappear() {
                            connectionService.stopHosting()
                        }
                }
                
                Spacer()
            }
            .navigationTitle("Remote Play")
            .background(Color("Background"))
        }
//        .navigationDestination(for: Int.self, destination: { value in
////            ServerPlayerCustomiseView()
//            Text("Test")
//        })
        .navigationDestination(isPresented: $showGameSetup, destination: {
            ServerPlayerCustomiseView(connectionService: $connectionService, navigation: $navigation, clientType: clientType)
//            ServerPlayerCustomiseView(connectionService: connectionService)
        })
        .onChange(of: navigation, perform: { newValue in
            print(navigation)
        })
        .onAppear() {
            connectionService = ConnectionService()
            connectionService.delegate = self
            showGameSetup = false
        }
        .onChange(of: clientType) { _ in
            connectionService.delegate = self
        }
    }
    
    func connecting(to peer: MCPeerID) {
        // Showing connecting thing
    }
    
    func connected(to peer: MCPeerID) {
        // transition to game setup page
//        navigation.append(3)
        showGameSetup = true
    }
}


struct HostConnectionView: View, ConnectionServiceHostDelegate {
    @State var potentialConnections: [PotentialConnection] = []
    
    @Binding var connectionService: ConnectionService
    
    var body: some View {
        VStack(spacing: 0) {
            if potentialConnections.isEmpty {
                ProgressView()
                HStack {
                    Spacer()
                    Text("Waiting for a player to join...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
            } else {
                List {
                    Section {
                        ForEach(potentialConnections, id: \.self.peerID) { potentialConnection in
                            HStack {
                                Text(potentialConnection.peerID.displayName)
                                
                                Spacer()
                                
                                Button {
                                    // Accept the connection
                                    connectionService.hostDelegate = self
                                    potentialConnection.handler(true, potentialConnection.session)
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }.buttonStyle(PlainButtonStyle())
                                
                                Button {
                                    // Decline the connection
                                    connectionService.hostDelegate = self
                                    potentialConnection.handler(false, nil)
                                    potentialConnections.removeAll(where: { $0.peerID == potentialConnection.peerID })
                                } label: {
                                    Image(systemName: "x.circle.fill")
                                        .foregroundColor(.red)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }
                    } header: {
                        Text("Incoming Requests: ")
                    }
                }
            }
        }
        .onAppear {
            potentialConnections = []
            connectionService.hostDelegate = self
        }
        .onChange(of: potentialConnections) { _ in
            connectionService.hostDelegate = self
        }
    }
    
    func receivedConnectionRequest(from peerID: MCPeerID, invitationHandler: @escaping (Bool, MCSession?) -> Void, session: MCSession) {
        print("Removing " + peerID.displayName + " from list")
        potentialConnections.append(PotentialConnection(peerID: peerID, session: session, handler: invitationHandler))
    }
}


struct JoinConnectionView: View, ConnectionServiceClientDelegate {
    
    @State var availableHosts: [MCPeerID] = []
    
    @Binding var connectionService: ConnectionService
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                List {
                    Section {
                        ForEach(availableHosts, id: \.self) { host in
                            HStack {
                                Text(host.displayName)
                                
                                Spacer()
                                
                                Button {
                                    // Send join request
                                    connectionService.clientDelegate = self
                                    connectionService.sendJoinRequest(peer: host)
                                } label: {
                                    Text("Join")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .padding(7.5)
                                        .background {
                                            RoundedRectangle(cornerRadius: 7.5)
                                                .foregroundColor(.blue)
                                        }
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }
                    } header: {
                        Text("Available Games:")
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            availableHosts = []
            connectionService.clientDelegate = self
        }
    }
    func foundHost(_ peerID: MCPeerID) {
        availableHosts.append(peerID)
    }
    func lostHost(_ peerID: MCPeerID) {
        print("host lost: " + peerID.displayName)
        availableHosts.removeAll(where: { $0.displayName == peerID.displayName })
    }
}

struct ServerSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelectView(navigation: .constant([]))
    }
}
