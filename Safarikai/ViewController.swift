//
//  ViewController.swift
//  Safarikai
//
//  Created by James Chen on 2016/11/26.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import Cocoa
import SafarikaiEngine

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        SafarikaiEngine.Dictionary.test()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

