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

    struct Keys {
        static let lookupEnabled = "lookupEnabled"
        static let highlightEnabled = "highlightEnabled"
        static let romajiShow = "romajiShow"
        static let translationShow = "translationShow"
        static let shouldLookupOnlyOnHotkey = "lookupOnlyOnHotkey"
        static let shouldLookupImgAlt = "lookupImgAlt"
        static let resultsLimit = "resultsLimit"
    }

    var isLookupEnabled: Bool {
        get { return sharedUserDefaults.value(forKey: Keys.lookupEnabled) as? Bool ?? true }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.lookupEnabled) }
    }

    var isHighlightEnabled: Bool {
        get { return sharedUserDefaults.value(forKey: Keys.highlightEnabled) as? Bool ?? true }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.highlightEnabled) }
    }

    var isShowRomaji: Bool {
        get { return sharedUserDefaults.value(forKey: Keys.romajiShow) as? Bool ?? true }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.romajiShow) }
    }

    var isShowTranslation: Bool {
        get { return sharedUserDefaults.value(forKey: Keys.translationShow) as? Bool ?? true }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.translationShow) }
    }

    var shouldLookupOnlyOnHotkey: Bool {
        get { sharedUserDefaults.value(forKey: Keys.shouldLookupOnlyOnHotkey) as? Bool ?? true }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.shouldLookupOnlyOnHotkey) }
    }

    var shouldLookupImgAlt: Bool {
        get { sharedUserDefaults.value(forKey: Keys.shouldLookupImgAlt) as? Bool ?? true }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.shouldLookupImgAlt) }
    }

    var resultsLimit: Int {
        get { return max(3, sharedUserDefaults.integer(forKey: Keys.resultsLimit)) }
        set(value) { sharedUserDefaults.set(value, forKey: Keys.resultsLimit) }
    }
}
