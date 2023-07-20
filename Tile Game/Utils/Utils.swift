//
//  Utils.swift
//  Tile Game
//
//  Created by Jack Allie on 17/1/2023.
//

import Foundation
import AVFoundation
import UIKit.UIFeedbackGenerator

class Utils {
    
    private static var audioPlayer: AVAudioPlayer?
    
    public static let gameEndSoundURL = URL(fileURLWithPath: Bundle.main.path(forResource: "gameEndSound", ofType: "wav")!)
    public static let tilePlacedURL = URL(fileURLWithPath: Bundle.main.path(forResource: "tilePlaced.wav", ofType: nil)!)
    public static let achieveSoundURL = URL(fileURLWithPath: Bundle.main.path(forResource: "achievement_sound.wav", ofType: nil)!)
    public static var numPlayedSession = 0
    
    public static func formatDuration(_ duration: Int) -> String {
        let mins = Int(duration / 60)
        let secs = duration - 60*mins
        return String(format: "%02d:%02d", mins, secs)
    }
    
    /**
     Plays the given sound effect if sound settings allows
     */
    public static func playSound(withVolume vol: Float, url: URL) {
        if SettingsData.instance.getSoundDisabled() { return }
        do {
            if audioPlayer?.isPlaying ?? false { return }
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.setVolume(vol, fadeDuration: 0)
            audioPlayer?.play()
        } catch {
            print("Failed to load sound")
        }
    }
    
    public static func playSound(_ url: URL) {
        playSound(withVolume: 1.0, url: url)
    }
    
    public static func playLightHaptic() {
        if SettingsData.instance.getHapticsDisabled() { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    public static func playMediumHaptic() {
        if SettingsData.instance.getHapticsDisabled() { return }
        UIImpactFeedbackGenerator().impactOccurred()
    }
    
    public static func playSuccessHaptic() {
        if SettingsData.instance.getHapticsDisabled() { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    public static func canReqReview() -> Bool {
        let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        if !UserDefaults.standard.bool(forKey: "hasShownReviewFor\(versionNumber ?? "0.0")") && Utils.numPlayedSession >= 3 {
            UserDefaults.standard.set(true, forKey: "hasShownReviewFor\(versionNumber ?? "0.0")")
            return true
        }
        
        return false
    }
}

extension String {
    func rightPad(_ padString: String, toLength: Int) -> String {
        if self.count >= toLength { return self }
        
        let diff = toLength - self.count
        var padding = ""
        
        for _ in 0..<diff {
            padding += padString
        }
        
        return self.appending(padding)
    }
}
