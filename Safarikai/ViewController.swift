//
//  ViewController.swift
//  Safarikai
//
//  Created by James Chen on 2016/11/26.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBAction func openSafariExtPrefsPressed(_ sender: Any) {
        let myAppleScript = """
            tell application "Safari" to activate
            tell application "System Events" to tell process "Safari"
                keystroke "," using command down
                tell window 1
                    click button "Extensions" of tool bar 1
                    activate "Extensions"
                end tell
            end tell
        """
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("error: \(error)")
            }
        }
    }
}

