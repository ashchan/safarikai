//
//  DictionaryFileManager.swift
//  Safarikai
//
//  Created by James Chen on 2016/11/29.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import Cocoa
import SQLite

public class DictionaryFileManager: NSObject {
    public static let `default` = DictionaryFileManager()

    private override init() {}

    var handle: OpaquePointer? = nil

    public func directory() -> URL {
        let rootDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.ashchan.Safarikai")!
        return rootDirectory.appendingPathComponent("Dict")
    }

    public func test() {
        let dbPath = directory().appendingPathComponent("jmdict.sqlite3").absoluteString
        let db = try! Connection(dbPath)
        for row in try! db.prepare("select entry, kanji from kanji where entry = 1000200") {
            print("kanji: \(row[1])")
        }
    }
}
