//
//  SafariExtensionViewController.swift
//  Safari Extension
//
//  Created by James Chen on 2016/11/26.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared = SafariExtensionViewController()
    
    @IBOutlet weak var lookupButton: NSButton!
    @IBOutlet weak var highlightButton: NSButton!
    @IBOutlet weak var romajiButton: NSButton!
    @IBOutlet weak var translationButton: NSButton!
    @IBOutlet weak var resultLimitPopUp: NSPopUpButton!
    
    private let resultOptions = Array(3...8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = NSSize(width: 175, height: 150)
        
        lookupButton.state = SettingsManager.shared.isLookupEnabled ? .on : .off
        highlightButton.state = SettingsManager.shared.isHighlightEnabled ? .on : .off
        romajiButton.state = SettingsManager.shared.isShowRomaji ? .on : .off
        translationButton.state = SettingsManager.shared.isShowTranslation ? .on : .off
        resultLimitPopUp.addItems(withTitles: resultOptions.map {"\($0)"})
        resultLimitPopUp.selectItem(withTitle: "\(SettingsManager.shared.resultsLimit)")
    }
    
    @IBAction func lookupTogglePressed(_ sender: NSButton) {
        SettingsManager.shared.isLookupEnabled = sender.state == .on
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
