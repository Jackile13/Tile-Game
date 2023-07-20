//
//  StatisticsView.swift
//  Tile Game
//
//  Created by Jack Allie on 20/1/2023.
//

import SwiftUI

struct StatisticsView: View {
    
    @State var localStats: [LocalStatistics] = []
    @State var remoteStats: [RemoteStatistics] = []
    
    var body: some View {
        VStack {
            ScrollView {
                LocalStatisticsView(stats: $localStats)
//                    .background(Color(uiColor: UIColor.systemBackground))
                    .background(Color("ButtonColour"))
                    .cornerRadius(20)
                    .padding()
                
                RemoteStatisticsView(stats: $remoteStats)
//                    .background(Color(uiColor: UIColor.systemBackground))
                    .background(Color("ButtonColour"))
                    .cornerRadius(20)
                    .padding()
            }
        }
        .background(Color("Background"))
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Statistics")
        .onAppear() {
//            DispatchQueue.global(qos: .userInteractive).async {
            print("UI commence reading of stats")
                localStats = MainStatistics.readStatsFile(atURL: MainStatistics.localStatsPath)
                remoteStats = MainStatistics.readStatsFile(atURL: MainStatistics.remoteStatsPath)
//            }
        }
    }
}

struct LocalStatisticsView: View {
    
    @State var matchesPlayed: String = "0"
    @State var player1Wins: String = "0"
    @State var player2Wins: String = "0"
    @State var draws: String = "0"
    @State var averageMatchDuration: String = "--:--"
    @State var totalTilesPlaced: String = "0"
    @State var totalTilesConverted: String = "0"
    @State var highestScore: String = "0"
    
    @Binding var stats: [LocalStatistics]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Local Statistics")
                .font(.title)
                .monospaced()
            
            Divider()
            
            Group {
                StatView(label: "Matches Played", value: $matchesPlayed)
                StatView(label: "Player 1 Wins", value: $player1Wins)
                StatView(label: "Player 2 Wins", value: $player2Wins)
                StatView(label: "Draws", value: $draws)
                StatView(label: "Highest Score", value: $highestScore)
                StatView(label: "Average Match Duration", value: $averageMatchDuration)
                StatView(label: "Total Tiles Placed", value: $totalTilesPlaced)
                StatView(label: "Total Tiles Converted", value: $totalTilesConverted)
            }
            .padding(.top)
            
            NavigationLink {
                StatisticDetailsView(localStats: stats)
            } label: {
                HStack {
                    Text("See more")
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.top)

        }
        .padding()
        .onChange(of: stats) { _ in
            print("Stats changed: \(stats)")
            calcStats()
        }
    }
    
    private func calcStats() {
        let p1Wins = stats.filter({ $0.p1Score > $0.p2Score }).count
        let p2Wins = stats.filter({ $0.p2Score > $0.p1Score }).count
        player1Wins = String(p1Wins)
        player2Wins = String(p2Wins)
        draws = String(stats.count - p1Wins - p2Wins)
        
        var totalMatchSeconds = 0
        
        for stat in stats {
            totalMatchSeconds += stat.matchDuration
            totalTilesPlaced = String(Int(totalTilesPlaced)! + stat.p1TilesPlaced + stat.p2TilesPlaced)
            totalTilesConverted = String(Int(totalTilesConverted)! + stat.p1TilesConverted + stat.p2TilesConverted)
            
            if stat.p1Score > Int(highestScore)! { highestScore = String(stat.p1Score) }
            if stat.p2Score > Int(highestScore)! { highestScore = String(stat.p2Score) }
        }
        
        
        let averageMatchSeconds = totalMatchSeconds / stats.count
        let averageMins = Int(averageMatchSeconds / 60)
        let averageSecs = averageMatchSeconds - averageMins*60
        averageMatchDuration = String(format: "%02d:%02d", averageMins, averageSecs)
        
        matchesPlayed = String(stats.count)
    }
}

struct RemoteStatisticsView: View {
    
    @State var matchesPlayed: String = "0"
    @State var wins: String = "0"
    @State var losses: String = "0"
    @State var draws: String = "0"
    @State var averageMatchDuration: String = "--:--"
    @State var tilesPlaced: String = "0"
    @State var tilesConverted: String = "0"
    @State var tilesLost: String = "0"
    @State var highestScore: String = "0"
    
    @Binding var stats: [RemoteStatistics]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Remote Statistics")
                .font(.title)
                .monospaced()
            
            Divider()
            
            Group {
                StatView(label: "Matches Played", value: $matchesPlayed)
                StatView(label: "Wins", value: $wins)
                StatView(label: "Losses", value: $losses)
                StatView(label: "Draws", value: $draws)
                StatView(label: "Highest Score", value: $highestScore)
                StatView(label: "Average Match Duration", value: $averageMatchDuration)
                StatView(label: "Tiles Placed", value: $tilesPlaced)
                StatView(label: "Tiles Converted", value: $tilesConverted)
                StatView(label: "Tiles Lost", value: $tilesLost)
            }
            .padding(.top)
            
            NavigationLink {
                StatisticDetailsView(remoteStats: stats)
            } label: {
                HStack {
                    Text("See more")
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.top)
        }
        .padding()
        .onChange(of: stats) { _ in
            calcStats()
        }
    }
    
    private func calcStats() {
        let ws = stats.filter { stat in
            if stat.didHost {
                // If host, your score is p1Score
                return stat.p1Score > stat.p2Score
            } else {
                // If not host, your score is p2Score
                return stat.p2Score > stat.p1Score
            }
        }.count
        let ls =  stats.filter { stat in
            if stat.didHost {
                // If host, your score is p1Score
                return stat.p1Score < stat.p2Score
            } else {
                // If not host, your score is p2Score
                return stat.p2Score < stat.p1Score
            }
        }.count
        wins = String(ws)
        losses = String(ls)
        draws = String(stats.count - ws - ls)
        
        var totalMatchSeconds = 0
        
        for stat in stats {
            totalMatchSeconds += stat.matchDuration
            
            if stat.didHost {
                // If didHost, stats are under p1
                tilesPlaced = String(Int(tilesPlaced)! + stat.p1TilesPlaced)
                tilesConverted = String(Int(tilesConverted)! + stat.p1TilesConverted)
                tilesLost = String(Int(tilesLost)! + stat.p2TilesConverted)
                if stat.p1Score > Int(highestScore)! { highestScore = String(stat.p1Score) }
            } else {
                // If did not host, stats are under p2
                tilesPlaced = String(Int(tilesPlaced)! + stat.p2TilesPlaced)
                tilesConverted = String(Int(tilesConverted)! + stat.p2TilesConverted)
                tilesLost = String(Int(tilesLost)! + stat.p1TilesConverted)
                if stat.p2Score > Int(highestScore)! { highestScore = String(stat.p2Score) }
            }
        }
        
        
        let averageMatchSeconds = totalMatchSeconds / stats.count
        let averageMins = Int(averageMatchSeconds / 60)
        let averageSecs = averageMatchSeconds - averageMins*60
        averageMatchDuration = String(format: "%2d:%2d", averageMins, averageSecs)
        
        matchesPlayed = String(stats.count)
    }
}

struct StatView: View {
    let label: String
    @Binding var value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
            Spacer()
            Text(value)
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
