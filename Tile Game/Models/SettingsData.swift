//
//  SettingsData.swift
//  Tile Game
//
//  Created by Jack Allie on 25/1/2023.
//

import Foundation


class SettingsData {
    
    public static var instance: SettingsData = SettingsData()
    
    // Settings values
    private var playerName: String = "Player 1"
    private var defaultGridSize: Int = 8
    private var soundDisabled: Bool = false
    private var hapticsDisabled: Bool = false
    
    // On initialisation, read from persistent UserDefaults database
    private init() {
        self.playerName = UserDefaults.standard.string(forKey: "playerName") ?? "Player 1"
        self.defaultGridSize = UserDefaults.standard.integer(forKey: "defaultGridSize")
        self.soundDisabled = UserDefaults.standard.bool(forKey: "soundDisabled")
        self.hapticsDisabled = UserDefaults.standard.bool(forKey: "hapticsDisabled")
        
        if self.defaultGridSize == 0 { defaultGridSize = 8 }
    }
    
    
    public func setPlayerName(_ name: String) {
        self.playerName = name
        UserDefaults.standard.set(name, forKey: "playerName")
    }
    
    public func getPlayerName() -> String {
        return self.playerName
    }
    
    public func setDefaultGridSize(_ size: Int) {
        self.defaultGridSize = size
        UserDefaults.standard.set(size, forKey: "defaultGridSize")
    }
    
    public func getDefaultGridSize() -> Int {
        return self.defaultGridSize
    }
    
    public func setSoundDisabled(_ isDisabled: Bool) {
        self.soundDisabled = isDisabled
        UserDefaults.standard.set(isDisabled, forKey: "soundDisabled")
    }
    
    public func getSoundDisabled() -> Bool {
        return self.soundDisabled
    }
    
    public func setHapticsDisabled(_ isDisabled: Bool) {
        self.hapticsDisabled = isDisabled
        UserDefaults.standard.set(isDisabled, forKey: "hapticsDisabled")
    }
    
    public func getHapticsDisabled() -> Bool {
        return self.hapticsDisabled
    }
    
}
