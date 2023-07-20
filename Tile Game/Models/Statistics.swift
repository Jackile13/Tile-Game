//
//  Statistics.swift
//  Tile Game
//
//  Created by Jack Allie on 9/1/2023.
//

import Foundation


// Contains relevant stats for a single round of local play
struct LocalStatistics: Codable, Equatable, Hashable {
    let date: Date
    let p1Name: String
    let p2Name: String
    let p1Type: PlayerType
    let p2Type: PlayerType
    let p1Colour: String
    let p2Colour: String
    let p1Score: Int
    let p2Score: Int
    let matchDuration: Int // seconds
    let gridSize: Int
    let p1TilesPlaced: Int
    let p2TilesPlaced: Int
    let p1TilesConverted: Int
    let p2TilesConverted: Int
    
    init(state: GameState, duration: Int, p1TilesConverted: Int, p2TilesConverted: Int) {
        self.date = Date()
        self.p1Name = state.player1.name
        self.p2Name = state.player2.name
        self.p1Type = state.player1.type
        self.p2Type = state.player2.type
        self.p1Score = state.playerScore1
        self.p2Score = state.playerScore2
        self.p1Colour = state.player1.colour
        self.p2Colour = state.player2.colour
        self.matchDuration = duration
        self.gridSize = state.gridSize
        self.p1TilesPlaced = state.gridSize * state.gridSize / 2 - 2
        self.p2TilesPlaced = state.gridSize * state.gridSize / 2 - 2
        self.p1TilesConverted = p1TilesConverted
        self.p2TilesConverted = p2TilesConverted
    }
}

struct RemoteStatistics: Codable, Equatable, Hashable {
    let date: Date
    let didHost: Bool
    let p1Name: String
    let p2Name: String
    let p1Colour: String
    let p2Colour: String
    let p1Score: Int
    let p2Score: Int
    let matchDuration: Int // seconds
    let gridSize: Int
    let p1TilesPlaced: Int
    let p2TilesPlaced: Int
    let p1TilesConverted: Int
    let p2TilesConverted: Int
    
    init(state: GameState, didHost: Bool, duration: Int, p1TilesConverted: Int, p2TilesConverted: Int) {
        self.date = Date()
        self.didHost = didHost
        self.p1Name = state.player1.name
        self.p2Name = state.player2.name
        self.p1Score = state.playerScore1
        self.p2Score = state.playerScore2
        self.p1Colour = state.player1.colour
        self.p2Colour = state.player2.colour
        self.matchDuration = duration
        self.gridSize = state.gridSize
        self.p1TilesPlaced = state.gridSize * state.gridSize / 2 - 2
        self.p2TilesPlaced = state.gridSize * state.gridSize / 2 - 2
        self.p1TilesConverted = p1TilesConverted
        self.p2TilesConverted = p2TilesConverted
    }
}


// Encapsulates saving and updating statistics
final class MainStatistics {
    
    private static let fm = FileManager()
    private static let path = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
    public static let localStatsPath: URL = path.appendingPathComponent("local_statistics", conformingTo: .fileURL)
    public static let remoteStatsPath: URL = path.appendingPathComponent("remote_statistics", conformingTo: .fileURL)
    
    /**
     Saves the given statistics object to a URL given by static values on this class
     */
    public static func saveStats<T: Codable>(_ stats: T, to url: URL) {
        
        print("Path = " + path.path())
        
        // If the stat file does not exist, create it
        if !fm.fileExists(atPath: url.path()) {
            print("No local stats file, creating...")
            do {
                let data = try JSONEncoder().encode([stats])
                fm.createFile(atPath: url.path(), contents: data)
            } catch {
                print("Could not save data to new file: " + error.localizedDescription)
            }
            return
        }
        
        do {
            // Read current stats file
            let fileData = try Data(contentsOf: url)
            var allStats: [T] = try JSONDecoder().decode([T].self, from: fileData)
            
            // Add new stats
            allStats.append(stats)
            
            // Encode data to JSON
            let newData = try JSONEncoder().encode(allStats)
            
            // Write data
            try newData.write(to: url)
            
        } catch {
            print("Error reading/writing local statisitcs data: " + error.localizedDescription)
        }
    }
    
    public static func readStatsFile<T: Codable>(atURL url: URL) -> [T] {
        print("Starting to read file")
        do {
            let data = try Data(contentsOf: url)
            let stats = try JSONDecoder().decode([T].self, from: data)
            
            print("Read in \(stats.count) stats")
            
            return stats
        } catch {
            print("Error reading data: " + error.localizedDescription)
        }
        
        return []
    }
    
    public static func removeStatisticsFile(atURL url: URL) {
        do {
            try fm.removeItem(at: url)
        } catch {
            print("Could not remove file at \(url): " + error.localizedDescription)
        }
    }
}
