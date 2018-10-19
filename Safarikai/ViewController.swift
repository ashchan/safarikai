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
    @IBOutlet weak var highlightButton: NSButton!
    @IBOutlet weak var romajiButton: NSButton!
    @IBOutlet weak var translationButton: NSButton!
    @IBOutlet weak var resultLimitPopup: NSPopUpButton!
    
    private let resultOptions = Array(3...8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        highlightButton.state = SettingsManager.shared.isHighlightEnabled ? .on : .off
        romajiButton.state = SettingsManager.shared.isShowRomaji ? .on : .off
        translationButton.state = SettingsManager.shared.isShowTranslation ? .on : .off
        resultLimitPopup.addItems(withTitles: resultOptions.map {"\($0)"})
        resultLimitPopup.selectItem(withTitle: "\(SettingsManager.shared.resultsLimit)")
    }
    
    // MARK: - IBAction
    
    @IBAction func openSafariPreferences(_ sender: Any) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.ashchan.Safarikai.Safari-Extension")
    }
    
    @IBAction func highlightTogglePressed(_ sender: NSButton) {
        SettingsManager.shared.isHighlightEnabled = sender.state == .on
    }
    
    @IBAction func romajiTogglePressed(_ sender: NSButton) {
        SettingsManager.shared.isShowRomaji = sender.state == .on
    }
    
    @IBAction func translationTogglePressed(_ sender: NSButton) {
        SettingsManager.shared.isShowTranslation = sender.state == .on
    }
    
    @IBAction func resultLimitPressed(_ sender: NSPopUpButton) {
        let selectedLimit = resultOptions[sender.indexOfSelectedItem]
        SettingsManager.shared.resultsLimit = selectedLimit
    }
}
