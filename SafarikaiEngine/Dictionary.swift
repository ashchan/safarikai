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
    public class func test() {
        let db = try! Connection(DictionaryFileManager.default.dbPath)
        for row in try! db.prepare("select entry, kanji from kanji where entry = 1000200") {
            print("kanji: \(row[1])")
        }
    }
}
