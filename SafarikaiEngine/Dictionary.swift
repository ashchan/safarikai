//
//  Dictionary.swift
//  Safarikai
//
//  Created by James Chen on 2016/12/05.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import Cocoa
import SQLite

public class Dictionary {
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

    class func test() {
        let db = try! Connection(DictionaryFileManager.default.dbPath)
        for row in try! db.prepare("select entry, kanji from kanji where entry = 1000200") {
            print("kanji: \(row[1])")
        }
    }

    public class func search(word: String, limit: Int = 5) -> [Result] {
        return [
            Result(kana: "じちく", kanji: "自治区", translation: "Territory", romaji: "jichiku"),
            Result(kana: "じち", kanji: "自治", translation: "Self-government", romaji: "jichi")
        ]
    }
}
