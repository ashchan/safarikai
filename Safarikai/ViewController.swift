//
//  ViewController.swift
//  Safarikai
//
//  Created by James Chen on 2016/11/26.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import Foundation
import SafarikaiEngine

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
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
            if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error) {
                print(output.stringValue)
            } else if (error != nil) {
                print("error: \(error)")
            }
        }
    }
}

