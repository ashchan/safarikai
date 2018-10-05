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
    private init() {
        isLookupEnabled = sharedUserDefaults.value(forKey: Keys.lookupEnabled.rawValue) as? Bool ?? true
        resultsLimit = sharedUserDefaults.value(forKey: Keys.resultsLimit.rawValue) as? Int ?? 5
    }

    let sharedUserDefaults = UserDefaults(suiteName: "9A3W22M8YB.group.com.ashchan.Safarikai")!

    enum Keys: String {
        case lookupEnabled
        case highlightEnabled
        case romajiShow
        case translationShow
        case resultsLimit
    }

    private var _isLookupEnabled: Bool!
    var isLookupEnabled: Bool {
        get { return _isLookupEnabled }
        set(value) {
            sharedUserDefaults.set(value, forKey: Keys.lookupEnabled.rawValue)
            _isLookupEnabled = value
        }
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

    private var _resultsLimit: Int!
    var resultsLimit: Int {
        get { return _resultsLimit }
        set(value) {
            sharedUserDefaults.set(value, forKey: Keys.resultsLimit.rawValue)
            _resultsLimit = value
        }
    }
}
