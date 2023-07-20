//
//  PlayerSelectView.swift
//  Tile Game
//
//  Created by Jack Allie on 8/1/2023.
//
// For local play - gives option to choose human player or AI and AI difficulty
// Choose colour and optionally a name for each player (cannot have the same colour)
// Choose size of board to play on
// Can start the game when ready

import SwiftUI

struct PlayerSelectView: View {
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @Binding var navigation: [Int]
    
    @State var player1: Player = Player(name: SettingsData.instance.getPlayerName(), number: 1, type: .human, colour: "Red")
    @State var player2: Player = Player(name: "Player 2", number: 2, type: .human, colour: "Dark Blue")
    @State var gridSize: Float = Float(SettingsData.instance.getDefaultGridSize())
    
    @State var showColourPicker: Int = 0
    
    @Namespace var colourPicker
    
    var body: some View {
        ZStack {
            Group {
                if hSizeClass == .compact {
                    // Vertical Layout
                    ScrollView {
                        VStack() {
                            PlayerOptionsView(player: $player1, showColourPicker: $showColourPicker, colourPicker: colourPicker)
                                .padding()
                            PlayerOptionsView(player: $player2, showColourPicker: $showColourPicker, colourPicker: colourPicker)
                                .padding()
                            GameOptions(size: $gridSize)
                                .padding()
                            
                            Spacer()
                            
                            NavigationLink {
                                LocalGame(navigation: $navigation, gameState: GameState(gridSize: Int(gridSize), player1: player1, player2: player2))
                            } label: {
                                Text("Start Game")
                                    .foregroundColor(.primary)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 7.5)
//                                            .foregroundColor(Color(uiColor: UIColor.systemBackground))
                                            .foregroundColor(Color("ButtonColour"))
                                            .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                                    }
                            }
                            .padding()
                        }
                    }
                    
                } else {
                    // Horizontal Layout
                    VStack {
                        HStack {
                            PlayerOptionsView(player: $player1, showColourPicker: $showColourPicker, colourPicker: colourPicker)
                            Spacer()
                            PlayerOptionsView(player: $player2, showColourPicker: $showColourPicker, colourPicker: colourPicker)
                        }.padding()
                        
                        GameOptions(size: $gridSize)
                            .padding()
                        
                        Spacer()
                        
                        NavigationLink {
                            LocalGame(navigation: $navigation, gameState: GameState(gridSize: Int(gridSize), player1: player1, player2: player2))
                        } label: {
                            Text("Start Game")
                                .foregroundColor(.primary)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 7.5)
//                                            .foregroundColor(Color(uiColor: UIColor.systemBackground))
                                        .foregroundColor(Color("ButtonColour"))
                                        .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                                }
                        }
                        .padding()
                    }
                }
            }
            .zIndex(9)
            .scaleEffect(showColourPicker != 0 ? 0.98:1.0)
            .blur(radius: showColourPicker != 0 ? 4:0)
            .disabled(showColourPicker != 0 )
            .onChange(of: player2.type) { _ in
                // Setup AI for p1
                switch player2.type {
                case .AI(.easy): player2.AIStrategy = AIEasyStrategy()
                case .AI(.medium): player2.AIStrategy = AIMediumStrategy()
                case .AI(.hard): player2.AIStrategy = AIHardStrategy()
                default: player2.AIStrategy = nil
                }
            }
            .onChange(of: player1.type) { _ in
                // Setup AI for p1
                switch player1.type {
                case .AI(.easy): player1.AIStrategy = AIEasyStrategy()
                case .AI(.medium): player1.AIStrategy = AIMediumStrategy()
                case .AI(.hard): player1.AIStrategy = AIHardStrategy()
                default: player1.AIStrategy = nil
                }
            }
        
        if showColourPicker == 1 {
            ColourPicker(player: $player1, showColourPicker: $showColourPicker, colourPicker: colourPicker)
                    .zIndex(10)
                    .padding()
            } else if showColourPicker == 2 {
                ColourPicker(player: $player2, showColourPicker: $showColourPicker, colourPicker: colourPicker)
                    .zIndex(10)
                    .padding()
            } else {}
            
        }
        .navigationTitle("Game Setup")
        .background(Color("Background"))
        .onAppear() {
            if gridSize == 0 { gridSize = 8 }
        }
    }
}

struct PlayerSelectView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSelectView(navigation: .constant([]))
    }
}

struct PlayerOptionsView: View {
    
    @Binding var player: Player
    @Binding var showColourPicker: Int
    
    var colourPicker: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading) {
            // Use available width
            HStack {
                Spacer()
                Spacer()
            }
            
            Text("Player \(player.number):")
                .font(.headline)
                .foregroundColor(.gray)
            
            // Player type menu
            Menu {
                Button {
                    player.type = .human
                } label: {
                    Text(PlayerType.human.toString())
                }
                
                Button {
                    player.type = .AI(.easy)
                } label: {
                    Text(PlayerType.AI(.easy).toString())
                }
                
                Button {
                    player.type = .AI(.medium)
                } label: {
                    Text(PlayerType.AI(.medium).toString())
                }
                
                Button {
                    player.type = .AI(.hard)
                } label: {
                    Text(PlayerType.AI(.hard).toString())
                }
            } label: {
                HStack {
                    Text("Player Type: " + player.type.toString().rightPad(" ", toLength: 14))
                        .multilineTextAlignment(.leading)
                    Image(systemName: "chevron.up.chevron.down")
                        .scaleEffect(0.75)
                }
                .padding(7.5)
                .background {
                    RoundedRectangle(cornerRadius: 7.5)
//                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        .foregroundColor(Color("ButtonColour"))
//                        .shadow(radius: 2, y: 1)
                        .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                }
            }
            .foregroundColor(.primary)
            
            // Colour picker button
            Button {
                withAnimation(.easeInOut) {
                    showColourPicker = player.number
                }
            } label: {
                HStack {
                    Text("Colour: " + player.colour)
                    Circle()
                        .foregroundColor(Color(player.colour))
                        .frame(width: 20, height: 20)
                }
                .padding(7.5)
                .background {
                    RoundedRectangle(cornerRadius: 7.5)
//                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        .foregroundColor(Color("ButtonColour"))
//                        .shadow(radius: 2, y: 1)
                        .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                        .matchedGeometryEffect(id: player.number, in: colourPicker, isSource: true)
                }
            }
            
            // Player name chooser
            TextField("Player Name", text: $player.name)
                .padding()
//                .background(Color(uiColor: UIColor.systemBackground))
                .background(Color("ButtonColour"))
                .cornerRadius(7.5)
                .zIndex(9)
                .shadow(color: Color.gray.opacity(0.15), radius: 2, y: 1)
        }
        .foregroundColor(.primary)
    }
}


struct GameOptions: View {
    
    @Binding var size: Float
    let maxSize: Float = 10
    let minSize: Float = 4
    let rectSize: CGFloat = 15
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Grid Size: " + String(format: "%.0f", size))
                .font(.headline)
                .foregroundColor(.gray)
            
            HStack {
                Text("4")
                Slider(value: $size.animation(), in: minSize...maxSize, step: 2)
                Text("10")
            }
            
            HStack {
                Spacer()
                Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                    ForEach(0..<10, id: \.self) { row in
                        GridRow {
                            ForEach(0..<10, id: \.self) { col in
                                RoundedRectangle(cornerRadius: 2)
                                    .transition(.opacity)
//                                    .opacity(showPreviewSquare(row: row, col: col) ? 1:0)
                                    .frame(width: rectSize, height: rectSize)
//                                    .foregroundColor(Color(uiColor: .systemGray3))
                                    .foregroundColor(showPreviewSquare(row: row, col: col) ? .blue:.blue.opacity(0.25))
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
    
    private func showPreviewSquare(row: Int, col: Int) -> Bool {
        let offset: Int = Int((maxSize - size) / 2)
        
        if row < offset || row >= (Int(maxSize) - offset) { return false }
        if col < offset || col >= (Int(maxSize) - offset) { return false }
        return true
    }
}

/**
 Shows a grid of colours to be chosen, selecting a colour picks it for a player
 */
struct ColourPicker: View {
    
    @Binding var player: Player
    @Binding var showColourPicker: Int
    
    var colourPicker: Namespace.ID
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    @State var showGrid = false
    
    var body: some View {
        ZStack {
            // Background rectangle to detect closing the colour picker
            Rectangle()
                .opacity(0.0001)
                .onTapGesture {
                    withAnimation {
                        showGrid = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut) {
                            showColourPicker = 0
                        }
                    }
                }
            
            // Grid of colours
            LazyVGrid(columns: columns) {
                ForEach(colourStrings, id:\.self) { colour in
                    VStack {
                        Circle()
                            .foregroundColor(Color(colour))
                            .frame(width: 50)
                            .scaleEffect(player.colour == colour ? 1:0.7)
                        Text(colour.description)
                            .foregroundColor(.primary)
                    }.onTapGesture {
                        // Change colour
                        withAnimation {
                            player.colour = colour
                        }
                    }
                }
            }
            .opacity(showGrid ? 1:0.0001)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
//                    .foregroundColor(Color(uiColor: .systemBackground))
                    .foregroundColor(Color("ButtonColour"))
//                    .shadow(radius: 2, y: 1)
                    .shadow(color: Color.gray.opacity(0.45), radius: 2, y: 1)
                    .matchedGeometryEffect(id: player.number, in: colourPicker, isSource: true)
                    .zIndex(10)
            }
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        showGrid = true
                    }
                }
            }
        }
    }
}

