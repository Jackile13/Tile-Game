//
//  Help.swift
//  Tile Game
//
//  Created by Jack Allie on 20/1/2023.
//

import SwiftUI

struct Help: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var page = 1 {
        willSet {
            previousPage = page
        }
    }
    @State var previousPage = 1
    
    @State var edge1: Edge = .leading
    @State var edge2: Edge = .trailing
    @State var edge3: Edge = .trailing
    @State var edge4: Edge = .trailing
    
    var body: some View {
        VStack {
            switch page {
            case 2:
                HelpPage2()
                    .transition(.move(edge: edge2))
            case 3:
                HelpPage3()
                    .transition(.move(edge: edge3))
            case 4:
                HelpPage4()
                    .transition(.move(edge: edge4))
            default:
                // Page 1
                HelpPage1()
                    .transition(.move(edge: edge1))
            }
            
            HStack {
                Button {
                    getCurrentEdges(nextPage: page - 1)
                    withAnimation {
                        page -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                }
                .opacity(page == 1 ? 0.5:1.0)
                .disabled(page == 1)
                
                Spacer()
                
//                Button("Done") {
//                    dismiss.callAsFunction()
//                }
//                .opacity(page == 4 ? 1.0:0.0)
//                .disabled(page != 4)
//
//                Spacer()
                
                if page != 4 {
                    Button {
                        getCurrentEdges(nextPage: page + 1)
                        withAnimation {
                            page += 1
                        }
                    } label: {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                    }
                } else {
                    Button("Done") {
                        dismiss.callAsFunction()
                    }
                }
//                .opacity(page == 4 ? 0.5:1.0)
//                .disabled(page == 4)
            }
            .padding()
        }
        .background(Color("Background"))
        .onChange(of: page) { _ in
            getEdges()
        }
    }
    
    private func getEdges() {
//        if page < 2 {
//            edge2 = .trailing
//        } else if page > 2 {
//            edge2 = .leading
//        }
//        if page < 3 {
//            edge3 = .trailing
//        } else {
//            edge3 = .leading
//        }
    }
    
    private func getCurrentEdges(nextPage: Int) {
        if page == 2 {
            if nextPage == 1 {
                edge2 = .trailing
            } else if nextPage == 3 {
                edge2 = .leading
            }
        }
        
        if page == 3 {
            if nextPage == 2 {
                edge3 = .trailing
            } else if nextPage == 4 {
                edge3 = .leading
            }
        }
    }
    
}

struct HelpPage1: View {
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Parille")
//                    .bold()
                    .monospaced()
                    .font(.largeTitle)
                Spacer()
            }
            
            Spacer()
            
            // Image of a grid filled up
            Image("parille_eg")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(50)
            
            Group {
                Text("The goal of Parille is to convert as many tiles to your colour as possible by the time the grid fills up.")
                Text("Each player takes turns placing tiles on the grid adjacent to an already placed tile.")
            }
            .padding([.horizontal, .top])
            .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

struct HelpPage2: View {
    
    @Environment(\.colorScheme) var colourMode
    @State var showGif = false
    
    var body: some View {
        VStack {
            Text("The other player's tiles can be converted to your tiles by placing your tile so that it creates a line between another one of your tiles. This can be done...")
                .font(.body)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
            
            HStack {
                Spacer()
                
                Text("vertically...")
                    .padding()
                Spacer()
            }
            
            GifView("convert_vertical" + (colourMode == .dark ? "_dark":""))
                .frame(width: (270 / 2), height: (540 / 2))
                .opacity(showGif ? 1.0:0.0)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation { showGif = true }
            }
        }
    }
}

struct HelpPage3: View {
    
    @Environment(\.colorScheme) var colourMode
    @State var showGif = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                Text("...horizontally...")
                Spacer()
            }
            
            GifView("convert_horizontal" + (colourMode == .dark ? "_dark":""))
                .frame(width: (550 / 2.25), height: (280 / 2.25))
                .opacity(showGif ? 1.0:0.0)
            Spacer()
            Text("and diagonally.")
            GifView("convert_diagonal" + (colourMode == .dark ? "_dark":""))
                .frame(width: (550 / 2.25), height: (550 / 2.25))
                .opacity(showGif ? 1.0:0.0)
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation { showGif = true }
            }
        }
    }
}

struct HelpPage4: View {
    
    @Environment(\.colorScheme) var colourMode
    
    @State var showGif = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                Text("You can convert many squares with one move.")
                    .padding()
                Spacer()
            }
            
            GifView("convert_many" + (colourMode == .dark ? "_dark":""))
                .frame(width: (550 / 2), height: (545 / 2))
                .opacity(showGif ? 1.0:0.0)
            
            Spacer()
        }.onAppear {
            withAnimation { showGif = true }
        }
    }
}

struct Help_Previews: PreviewProvider {
    static var previews: some View {
        Help()
    }
}
