//
//  SafariExtensionHandler.swift
//  Safari Extension
//
//  Created by James Chen on 2016/11/26.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import SafariServices
import SafarikaiEngine

class SafariExtensionHandler: SFSafariExtensionHandler {
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        if !SafarikaiEngine.JSDictionary.shared.isEnabled {
            return
        }
        
        if messageName == "lookupWord" {
            let word = userInfo!["word"] as! String
            let url = userInfo!["url"] as! String
            let (results, match) = SafarikaiEngine.JSDictionary.shared.search(word: word)
            page.dispatchMessageToScript(withName: "showResult", userInfo:
                ["word": match ?? "", "url": url, "result": results]
            )
        }
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        SafarikaiEngine.JSDictionary.shared.isEnabled = !SafarikaiEngine.JSDictionary.shared.isEnabled
        window.getToolbarItem { (toolbarItem) in
            toolbarItem?.setBadgeText(SafarikaiEngine.JSDictionary.shared.isEnabled ? "ON" : "OFF")
        }
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, SafarikaiEngine.JSDictionary.shared.isEnabled ? "ON" : "OFF")
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
}
