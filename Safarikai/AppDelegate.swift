//
//  AppDelegate.swift
//  Safarikai
//
//  Created by James Chen on 2016/11/26.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import Cocoa
import SafarikaiEngine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let dir = DictionaryFileManager.default.directory()
        print(try! String(contentsOf: dir.appendingPathComponent("test.txt")))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

