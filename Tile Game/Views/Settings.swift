//
//  Settings.swift
//  Tile Game
//
//  Created by Jack Allie on 20/1/2023.
//

import SwiftUI

struct Settings: View {
    
    @Environment(\.openURL) var openURL
    
    @State var playerName = SettingsData.instance.getPlayerName()
    @State var defaultGridSize = SettingsData.instance.getDefaultGridSize()
//    @State var defaultAI: DifficultyType = DifficultyType.medium
    @State var soundsOn = !SettingsData.instance.getSoundDisabled()
    @State var hapticsOn = !SettingsData.instance.getHapticsDisabled()
    
    let email: URL = URL(string: "mailto:support@quinnscomputing.com".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
    var versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let moreAppsUrl = URL(string: "https://apps.apple.com/us/developer/aiden-quinn/id1525720516")!
    let reviewLink = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1666184682&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software")!
    
    var body: some View {
        VStack {
            Form {
                Section("Player Name") {
                    TextField("Name", text: $playerName)
                        .onChange(of: playerName) { _ in
                            print("Saving player name")
                            SettingsData.instance.setPlayerName(playerName)
                        }
                }
                
                Section("Settings") {
                    Picker("Default Grid Size:", selection: $defaultGridSize) {
                        Button("4") { defaultGridSize = 4 }.tag(4)
                        Button("6") { defaultGridSize = 6 }.tag(6)
                        Button("8") { defaultGridSize = 8 }.tag(8)
                        Button("10") { defaultGridSize = 10 }.tag(10)
                    }
                    .onChange(of: defaultGridSize) { _ in
                        print("Saving default grid size")
                        SettingsData.instance.setDefaultGridSize(defaultGridSize)
                    }
                    
//                    Picker("Default AI Difficulty:", selection: $defaultAI) {
//                        Button("Easy") { defaultAI = .easy }.tag(DifficultyType.easy)
//                        Button("Medium") { defaultAI = .medium }.tag(DifficultyType.medium)
//                        Button("Hard") { defaultAI = .hard }.tag(DifficultyType.hard)
//                    }
                    Toggle(isOn: $soundsOn) {
                        Text("Sound:")
                    }
                    .onChange(of: soundsOn) { _ in
                        print("Saving sound on")
                        SettingsData.instance.setSoundDisabled(!soundsOn)
                    }
                    
                    Toggle(isOn: $hapticsOn) {
                        Text("Haptics:")
                    }
                    .onChange(of: hapticsOn) { _ in
                        print("Saving haptics on")
                        SettingsData.instance.setHapticsDisabled(!hapticsOn)
                    }
                    
                    NavigationLink("Reset Statistics", destination: DeleteStatsSettingsView())
                }
                
                Section("About") {
                    NavigationLink("How to Play") { Help() }
                    Button("More Apps") { openURL(moreAppsUrl) }
                    Button("Rate & Review") { openURL(reviewLink) }
                    Button("Support") { openURL(email) }
                }
            }
            
            
            HStack {
                Text("Parille v" + (versionNumber ?? "0.0"))
                Spacer()
                Text("© 2023 Jack Allie")
            }
            .padding()
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Parille Settings")
        .background(Color("Background"))
        .onAppear {
            playerName = SettingsData.instance.getPlayerName()
            defaultGridSize = SettingsData.instance.getDefaultGridSize()
            soundsOn = !SettingsData.instance.getSoundDisabled()
            hapticsOn = !SettingsData.instance.getHapticsDisabled()
            
            print(playerName, defaultGridSize, soundsOn, hapticsOn)
        }
    }
}

struct DeleteStatsSettingsView: View {
    
    @State var showAlert = false
    @State var urls: [URL]? = nil
    @State var alertText = ""
    
    var body: some View {
        Form {
            Section {
                Group {
                    Button("Reset Local Statistics") {
                        urls = [MainStatistics.localStatsPath]
                        alertText = "Reset Local Statistics?"
                        showAlert = true
                    }
                    Button("Reset Remote Statistics") {
                        urls = [MainStatistics.remoteStatsPath]
                        alertText = "Reset Remote Statistics?"
                        showAlert = true
                    }
                    Button("Reset All Statistics") {
                        urls = [
                            MainStatistics.localStatsPath,
                            MainStatistics.remoteStatsPath
                        ]
                        alertText = "Reset All Statistics?"
                        showAlert = true
                    }
                }.foregroundColor(.red)
            }
        }
        .navigationTitle("Reset Statistics")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertText),
                message: Text("This cannot be undone"),
                primaryButton: .default(Text("Cancel")),
                secondaryButton: .destructive(Text("Delete")) {
                    if let urls {
                        for url in urls {
                            MainStatistics.removeStatisticsFile(atURL: url)
                        }
                    }
                })
        }

    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
