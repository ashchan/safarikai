//
//  SettingsManager.swift
//  Safarikai
//
//  Created by Aaron Lee on 2018/09/22.
//  Copyright © 2018 Aaron Lee. All rights reserved.
//

import Foundation

class SettingsManager {
    static let shared = SettingsManager()

    let sharedUserDefaults = UserDefaults(suiteName: "9A3W22M8YB.group.com.ashchan.Safarikai")!

    enum Keys: String {
        case lookupEnabled
        case highlightEnabled
        case romajiShow
        case translationShow
        case resultsLimit
    }

    var isLookupEnabled: Bool {
        get { return sharedUserDefaults.value(forKey: Keys.lookupEnabled.rawValue) as? Bool ?? true }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.lookupEnabled.rawValue) }
    }

    var isHighlightEnabled: Bool {
        get { return sharedUserDefaults.value(forKey: Keys.highlightEnabled.rawValue) as? Bool ?? true }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.highlightEnabled.rawValue) }
    }

    var isShowRomaji: Bool {
        get { return sharedUserDefaults.value(forKey: Keys.romajiShow.rawValue) as? Bool ?? true }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.romajiShow.rawValue) }
    }

    var isShowTranslation: Bool {
        get { return sharedUserDefaults.value(forKey: Keys.translationShow.rawValue) as? Bool ?? true }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.translationShow.rawValue) }
    }

    var resultsLimit: Int {
        get { return max(3, sharedUserDefaults.integer(forKey: Keys.resultsLimit.rawValue)) }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.resultsLimit.rawValue) }
    }
}
