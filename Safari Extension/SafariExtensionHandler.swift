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
        let dir = DictionaryFileManager.default.directory()
        //let db = try! String(contentsOf: dir.appendingPathComponent("jmdict.sqlite3"))

        if messageName == "lookupWord" {
            let word = userInfo!["word"] as! String
            let url = userInfo!["url"] as! String
            let result = [
                ["kana": "じちく", "kanji": "自治区", "translation": "todo", "romaji": "jichiku"],
                ["kana": "じち", "kanji": "自治", "translation": "todo", "romaji": "jichi"]
            ]
            page.dispatchMessageToScript(withName: "showResult", userInfo: ["word": word, "url": url, "result": result])
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
