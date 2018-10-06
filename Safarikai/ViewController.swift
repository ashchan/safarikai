//
//  ViewController.swift
//  Safarikai
//
//  Created by James Chen on 2016/11/26.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import Cocoa
import SafariServices

class ViewController: NSViewController {
    @IBAction func openSafariPreferences(_ sender: Any) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.ashchan.Safarikai.Safari-Extension")
    }
}
