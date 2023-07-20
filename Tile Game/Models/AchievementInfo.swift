//
//  AchievementInfo.swift
//  Tile Game
//
//  Created by Jack Allie on 27/1/2023.
//

import Foundation



class AchievementInfo: Equatable, ObservableObject {
    
    let text: String
    let subText: String
    
    init(text: String, subText: String) {
        self.text = text
        self.subText = subText
    }
    
    
    static func == (lhs: AchievementInfo, rhs: AchievementInfo) -> Bool {
        return lhs.text == rhs.text && lhs.subText == rhs.subText
    }
}

struct AchievementInfoList: Equatable {
    var achievements: [AchievementInfo]
    
    init() {
        achievements = []
    }
}

class AchievementInfoListModel: Equatable, ObservableObject {
    
    @Published var model = AchievementInfoList()
    
    static func == (lhs: AchievementInfoListModel, rhs: AchievementInfoListModel) -> Bool {
        return lhs.model == rhs.model
    }
}

class Test {
    static var achievements: [AchievementInfo] = []
}
