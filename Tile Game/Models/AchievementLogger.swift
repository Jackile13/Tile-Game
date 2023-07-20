//
//  AchievementLogger.swift
//  Tile Game
//
//  Created by Jack Allie on 26/1/2023.
//

import Foundation

class AchievementLogger: Codable {
    
    private var beatEasy: Bool = false
    private var beatMedium: Bool = false
    private var beatHardTimes: Int = 0
    private var beatHard10x10: Bool = false
    private var winRemoteGame: Bool = false
    private var remoteWinSteak: Int = 0
    private var maxRemoteWinStreak: Int = 0
    private var captureCorners: Bool = false
    
    public static var instance: AchievementLogger = AchievementLogger()
    
    private init() {
        // Read from file if exists (otherwise use default values)
        print("Init")
        
        let fm = FileManager()
        guard let path = fm.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("achievements", conformingTo: .json) else {
            print("URL cannot be realised")
            return
        }
        
        do {
            let data = try Data(contentsOf: path)
            let achievements = try JSONDecoder().decode(AchievementLogger.self, from: data)
            
            self.beatEasy = achievements.beatEasy
            self.beatMedium = achievements.beatMedium
            self.beatHardTimes = achievements.beatHardTimes
            self.beatHard10x10 = achievements.beatHard10x10
            self.remoteWinSteak = achievements.remoteWinSteak
            self.maxRemoteWinStreak = achievements.maxRemoteWinStreak
            self.captureCorners = achievements.captureCorners
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func getBeatEasy() -> Bool { return beatEasy }
    
    public func getBeatMedium() -> Bool { return beatMedium }
    
    public func getBeatHard() -> Bool { return beatHardTimes > 0 }
    
    public func getBeatHardTimes() -> Int { return beatHardTimes }
    
    public func getBeatHard10x10() -> Bool { return beatHard10x10 }
    
    public func getremoteWinStreak() -> Int { return remoteWinSteak }
    
    public func getMaxRemoteWinStreak() -> Int { return maxRemoteWinStreak }
    
    public func getWinRemoteGame() -> Bool { return winRemoteGame }
    
    public func getCaptureCorners() -> Bool { return captureCorners }
    
    public func setBeatEasy() {
        self.beatEasy = true
        saveStats()
    }
    
    public func setBeatMedium() {
        self.beatMedium = true
        saveStats()
    }
    
    public func incrementBeatHard() {
        self.beatHardTimes += 1
        saveStats()
    }
    
    /**
     Sets that the player beat hard AI on a 10x10 grid and increments beat hard
     */
    public func setBeatHard10x10() {
        self.beatHardTimes += 1
        self.beatHard10x10 = true
        saveStats()
    }
    
//    public func setWinRemoteGame() {
//        self.winRemoteGame = true
//        saveStats()
//    }
    
    public func lostRemoteGame() {
        self.remoteWinSteak = 0
        saveStats()
    }
    
    public func wonRemoteGame() {
        if !self.winRemoteGame { winRemoteGame = true }
        self.remoteWinSteak += 1
        if remoteWinSteak > maxRemoteWinStreak { maxRemoteWinStreak = remoteWinSteak }
        saveStats()
    }
    
    public func setCaptureCorners() {
        self.captureCorners = true
        saveStats()
    }
    
    private func saveStats() {
        
        let fm = FileManager()
        guard let path = fm.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("achievements", conformingTo: .json) else {
            print("URL cannot be realised")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(self)
            fm.createFile(atPath: path.path, contents: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}
