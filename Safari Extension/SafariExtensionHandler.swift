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
    private enum IncomingMessage: String {
        case queryStatus
        case lookupWord
    }

    private enum OutgoingMessage: String {
        case status
        case showResult
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
        if !SettingsManager.shared.isLookupEnabled {
            return
        }

        if messageName == IncomingMessage.lookupWord.rawValue {
            page.dispatchMessageToScript(withName: OutgoingMessage.status.rawValue, userInfo:
                ["enabled": SettingsManager.shared.isLookupEnabled,
                 "highlightText": SettingsManager.shared.isHighlightEnabled,
                 "showRomaji": SettingsManager.shared.isShowRomaji,
                 "showTranslation": SettingsManager.shared.isShowTranslation]
            )

            let word = userInfo!["word"] as! String
            let url = userInfo!["url"] as! String
            let limit = SettingsManager.shared.resultsLimit
            let (results, match) = Dict.shared.search(word, limit: limit)
            page.dispatchMessageToScript(withName: OutgoingMessage.showResult.rawValue, userInfo:
                ["word": match ?? "", "url": url, "result": results.map { $0.toJSON() }]
            )
        }

        if messageName == IncomingMessage.queryStatus.rawValue {
            page.dispatchMessageToScript(withName: OutgoingMessage.status.rawValue, userInfo:
                ["enabled": SettingsManager.shared.isLookupEnabled,
                 "highlightText": SettingsManager.shared.isHighlightEnabled,
                 "showRomaji": SettingsManager.shared.isShowRomaji,
                 "showTranslation": SettingsManager.shared.isShowTranslation]
            )
        }
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
}
