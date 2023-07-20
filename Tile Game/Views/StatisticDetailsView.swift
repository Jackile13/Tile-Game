//
//  StatisticDetailsView.swift
//  Tile Game
//
//  Created by Jack Allie on 21/1/2023.
//

import SwiftUI

struct StatisticDetailsView: View {
    
    var localStats: [LocalStatistics]? = nil
    var remoteStats: [RemoteStatistics]? = nil
    
    var body: some View {
        ScrollView {
            if localStats != nil {
                ForEach(localStats!, id: \.self) { stat in
                    LocalStatDetails(stat: stat)
                }
            }
            if remoteStats != nil {
                ForEach (remoteStats!, id:\.self) { stat in
                    RemoteStatDetails(stat: stat)
                }
            }
        }
        .navigationTitle(localStats == nil ? "Remote":"Local" + " Statistics")
        .background(Color("Background"))
    }
}

struct LocalStatDetails: View {
    
    let stat: LocalStatistics
    
    var body: some View {
        VStack {
            Text(stat.date.formatted(date: .numeric, time: .shortened))
            HStack {
                VStack(alignment: .leading) {
                    Text(stat.p1Name + " (" + stat.p1Type.toString() + ")")
                        .padding(2.5)
                        .foregroundColor(Color.white)
                        .background(Color(stat.p1Colour))
                        .cornerRadius(5)
                        .minimumScaleFactor(0.5)
                    Text("Score: \(stat.p1Score)")
                    Text("\(stat.p1TilesPlaced) tiles placed")
                    Text("\(stat.p1TilesConverted) tiles converted")
                }
                Spacer()
                Divider()
                Spacer()
                VStack(alignment: .trailing) {
                    Text(stat.p2Name + "(" + stat.p2Type.toString() + ")")
                        .padding(2.5)
                        .foregroundColor(Color.white)
                        .background(Color(stat.p2Colour))
                        .cornerRadius(5)
                        .minimumScaleFactor(0.5)
                    Text("Score: \(stat.p2Score)")
                    Text("\(stat.p2TilesPlaced) tiles placed")
                    Text("\(stat.p2TilesConverted) tiles converted")
                }
            }
            
            Group {
                StatView(label: "Grid Size", value: .constant(String(stat.gridSize) + "x" + String(stat.gridSize)))
                StatView(label: "Match Duration", value: .constant(Utils.formatDuration(stat.matchDuration)))
            }
        }
        .padding()
//         .background(Color(uiColor: UIColor.systemBackground))
        .background(Color("ButtonColour"))
        .cornerRadius(20)
        .padding([.horizontal, .top])
    }
}

struct RemoteStatDetails: View {
    
    let stat: RemoteStatistics
    
    var body: some View {
        VStack {
            Text(stat.date.formatted(date: .numeric, time: .shortened))
//            HStack {
//                VStack(alignment: .leading) {
//                    Text(stat.didHost ? (stat.p1Name + " (Host)"):(stat.p2Name + " (Host)"))
//                        .padding(2.5)
//                        .foregroundColor(Color.white)
//                        .background(Color(stat.didHost ? stat.p1Colour:stat.p2Colour))
//                        .cornerRadius(5)
//                    Text("Score: \(stat.didHost ? stat.p1Score:stat.p2Score)")
//                    Text("\(stat.didHost ? stat.p1TilesPlaced:stat.p2TilesPlaced) tiles placed")
//                    Text("\(stat.didHost ? stat.p1TilesConverted:stat.p2TilesConverted) tiles converted")
//                }
//                Spacer()
//                Divider()
//                Spacer()
//                VStack(alignment: .trailing) {
//                    Text(!stat.didHost ? (stat.p1Name):(stat.p2Name))
//                        .padding(2.5)
//                        .foregroundColor(Color.white)
//                        .background(Color(!stat.didHost ? stat.p1Colour:stat.p2Colour))
//                        .cornerRadius(5)
//                    Text("Score: \(stat.didHost ? stat.p2Score:stat.p1Score)")
//                    Text("\(stat.didHost ? stat.p2TilesPlaced:stat.p1TilesPlaced) tiles placed")
//                    Text("\(stat.didHost ? stat.p2TilesConverted:stat.p1TilesConverted) tiles converted")
//                }
//            }
            HStack {
                VStack(alignment: .leading) {
                    Text(stat.didHost ? (stat.p1Name + " (Host)"):stat.p2Name + " (Host)")
                        .padding(2.5)
                        .foregroundColor(Color.white)
                        .background(Color(stat.didHost ? stat.p1Colour:stat.p2Colour))
                        .cornerRadius(5)
                        .minimumScaleFactor(0.5)
                    Text("Score: \(stat.p1Score)")
                    Text("\(stat.p1TilesPlaced) tiles placed")
                    Text("\(stat.p1TilesConverted) tiles converted")
                }
                Spacer()
                Divider()
                Spacer()
                VStack(alignment: .trailing) {
                    Text(stat.didHost ? (stat.p2Name):(stat.p1Name))
                        .padding(2.5)
                        .foregroundColor(Color.white)
                        .background(Color(stat.didHost ? stat.p2Colour:stat.p1Colour))
                        .cornerRadius(5)
                        .minimumScaleFactor(0.5)
                    Text("Score: \(stat.p2Score)")
                    Text("\(stat.p2TilesPlaced) tiles placed")
                    Text("\(stat.p2TilesConverted) tiles converted")
                }
            }
            
            Group {
                StatView(label: "Grid Size", value: .constant(String(stat.gridSize) + "x" + String(stat.gridSize)))
                StatView(label: "Match Duration", value: .constant(Utils.formatDuration(stat.matchDuration)))
            }
        }
        .padding()
//        .background(Color(uiColor: UIColor.systemBackground))
        .background(Color("ButtonColour"))
        .cornerRadius(20)
        .padding([.horizontal, .top])
    }
}

struct StatisticDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticDetailsView()
    }
}
