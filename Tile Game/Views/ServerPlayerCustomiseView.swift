//
//  ServerPlayerCustomiseView.swift
//  Tile Game
//
//  Created by Jack Allie on 8/1/2023.
//
// Each player chooses their own colour and optionally a name (cannot have the same colour - grey out the colour selected by the other player)
// Host chooses board size
// Host and client both press "ready" button
// Host can start the game after both players are ready

import SwiftUI

struct ServerPlayerCustomiseView: View, MessageDelegate {
    
    @Environment(\.dismiss) var navDismiss
    
    @Binding var connectionService: ConnectionService
    @Binding var navigation: [Int]
    
    @State var showDisconnectAlert = false
    @State var showPlayerQuitAlert = false
    
    @State var clientType: ClientType
    @State var showColourPicker = 0
    @State var gridSize: Float = 8
    
    @Namespace var colourPicker
    
    @State var player1 = Player(name: SettingsData.instance.getPlayerName(), number: 1, type: .human, colour: "Dark Blue")
    @State var player2 = Player(name: "", number: 2, type: .human, colour: "Red")
    
    @State var helloReceived = false {
        didSet { print ("Received hello") }
    }
    @State var ready1 = false
    @State var ready2 = false   // Other player ready
    
    @State var startGame = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Group {
                    // MARK: - Player 1 Options
                    Text(player1.name + ":")
                        .foregroundColor(.gray)
                        .font(.headline)
                    
                    // Colour picker button
                    Button {
                        withAnimation(.easeInOut) {
                            showColourPicker = player1.number
                        }
                    } label: {
                        HStack {
                            Text("Colour: " + player1.colour)
                                .foregroundColor(.primary)
                            Circle()
                                .foregroundColor(Color(player1.colour))
                                .frame(width: 20, height: 20)
                        }
                        .padding(7.5)
                        .background {
                            RoundedRectangle(cornerRadius: 7.5)
//                                .foregroundColor(Color(uiColor: UIColor.systemBackground))
                                .foregroundColor(Color("ButtonColour"))
                                .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                                .matchedGeometryEffect(id: player1.number, in: colourPicker, isSource: true)
                        }
                    }
                    .padding(.bottom)
                    
                    // MARK: - Player 2 options
                    Text(player2.name + ":")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("Colour: " + player2.colour)
                            .foregroundColor(.primary)
                        Circle()
                            .foregroundColor(Color(player2.colour))
                            .frame(width: 20, height: 20)
                    }
                    .padding(7.5)
                    .background {
                        RoundedRectangle(cornerRadius: 7.5)
                            .foregroundColor(Color("ButtonColour"))
                            .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                    }
                    
                    
                    // MARK: Game options (grid size)
                    GameOptions(size: $gridSize)
                        .padding(.vertical)
                        .onChange(of: gridSize) { size in
                            if clientType == .host {
                                connectionService.sendMessage(msg: Message(key: .gridSizeChange, value: size))
                            }
                        }
                        .disabled(clientType == .client)
                }
                .opacity(ready1 ? 0.5:1)
                .disabled(ready1)
                
                    Spacer()
                    
                    // Ready and start buttons
                    HStack(spacing: 30) {
                        Spacer()
                        
                        Button {
                            ready1.toggle()
                            connectionService.sendMessage(msg: Message(key: .ready, value: ready1))
                        } label: {
                            Text(ready1 ? "Unready":"Ready  ")
                                .monospaced()
                                .foregroundColor(.primary)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 7.5)
                                        .foregroundColor(Color("ButtonColour"))
                                        .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                                }
                        }
                        
                        if clientType == .host {
                            Button {
                                startGame = true
                                connectionService.sendMessage(msg: Message(key: .startGame, value: ""))
                            } label: {
                                Text("Start Game")
                                    .monospaced()
                                    .foregroundColor(.primary)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 7.5)
                                            .foregroundColor(Color("ButtonColour"))
                                            .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                                    }
                            }
                            .opacity(ready1 && ready2 ? 1:0.5)
                            .disabled(!(ready1 && ready2))
                        }
                        
                        Spacer()
                    }
                
                
                HStack {
                    Spacer()
                    if ready1 && !ready2 {
                        Text("Waiting for other player to be ready...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else if !ready1 && ready2 {
                        Text("Other player ready")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text(" ")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .opacity(0)
                    }
                    Spacer()
                }
            }
            .padding()
            
            if showColourPicker == 1 {
                ColourPicker(player: $player1, showColourPicker: $showColourPicker, colourPicker: colourPicker)
                    .padding()
            }
        }
        .navigationDestination(isPresented: $startGame, destination: {
            RemoteGame(connectionService: $connectionService, navigation: $navigation, clientType: clientType, gameState: GameState(gridSize: Int(gridSize), player1: player1, player2: player2))
        })
        .alert("Disconnect?", isPresented: $showDisconnectAlert, actions: {
            Button("Disconnect") {
                connectionService.sendMessage(msg: Message(key: .quit, value: ""))
                navDismiss.callAsFunction()
            }
            Button("Cancel") {
                showDisconnectAlert = false
            }
        }, message: {
            Text("Are you sure you want to disconnect from this session?")
        })
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // Show alert to disconnect
                    showDisconnectAlert = true
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .bold()
                        Text("Back")
                    }
                }

            }
        })
        .navigationBarTitle("Game Setup")
        .onAppear() {
            
            // temporary name assigning
//            if clientType == .client { player1.name = "P2" }
            player1.name = SettingsData.instance.getPlayerName()
            
            connectionService.messageDelegate = self
//            print("Sending hello...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                connectionService.sendMessage(msg: Message(key: .hello, value: player1.name))
            }
            
            if clientType == .host {
                player1.colour = "Dark Blue"
                player2.colour = "Red"
            } else {
                player1.colour = "Red"
                player2.colour = "Dark Blue"
            }
        }
        .onChange(of: player1.colour) { newColour in
            connectionService.sendMessage(msg: Message(key: .colourChange, value: newColour))
        }
        .alert("Other Player Disconnected", isPresented: $showPlayerQuitAlert) {
            Button("Ok") { navDismiss.callAsFunction() }
        }
    }
    
    
    // MARK: - Message processing
    func receivedMessage(msg: Message) {
        switch msg.key {
        case .hello:
            helloReceived = true
            player2.name = msg.value
        case .colourChange:
            player2.colour = msg.value
        case .gridSizeChange:
            do {
                gridSize = try Float(msg.value, strategy: FloatingPointParseStrategy(format: .number))
            } catch {
                print("Failed to get grid size from message: " + error.localizedDescription)
            }
        case .ready:
            ready2 = msg.value == "true"
        case .quit:
            showPlayerQuitAlert = true
        case .startGame:
            startGame = true
        default: return
        }
    }
    
}

struct ServerPlayerCustomiseView_Previews: PreviewProvider {
    static var previews: some View {
        ServerPlayerCustomiseView(connectionService: .constant(ConnectionService()), navigation: .constant([]), clientType: .host)
//        ServerPlayerCustomiseView(connectionService: ConnectionService())
    }
}
