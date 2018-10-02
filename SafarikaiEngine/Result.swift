//
//  Result.swift
//  Safarikai
//
//  Created by James Chen on 2016/12/06.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import Foundation

public struct Result {
    let kana, kanji, translation, romaji: String

    public func toJSON() -> [String: String] {
        return [
            "kana": kana,
            "kanji": kanji,
            "translation": translation,
            "romaji": romaji
        ]
    }
}
