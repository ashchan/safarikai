//
//  DictionaryFileManager.swift
//  Safarikai
//
//  Created by James Chen on 2016/11/29.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import Cocoa

public class DictionaryFileManager: NSObject {
    public static let `default` = DictionaryFileManager()

    private override init() {}

    public func directory() -> URL {
        let rootDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.ashchan.Safarikai")!
        return rootDirectory.appendingPathComponent("Dict")
    }

    var dbPath: String {
        return directory().appendingPathComponent("jmdict.sqlite3").absoluteString
    }
}
