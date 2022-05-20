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

    override func beginRequest(with context: NSExtensionContext) {
        super.beginRequest(with: context)

        Dict.shared.load()
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
        if !SettingsManager.shared.isLookupEnabled {
            return
        }

        let statusInfo: [String: Any] = [
            "enabled": SettingsManager.shared.isLookupEnabled,
            "highlightText": SettingsManager.shared.isHighlightEnabled,
            "showRomaji": SettingsManager.shared.isShowRomaji,
            "showTranslation": SettingsManager.shared.isShowTranslation,
            "lookupOnlyOnHotkey": SettingsManager.shared.shouldLookupOnlyOnHotkey,
            "lookupImgAlt": SettingsManager.shared.shouldLookupImgAlt
        ]

        if messageName == IncomingMessage.lookupWord.rawValue {
            page.dispatchMessageToScript(withName: OutgoingMessage.status.rawValue, userInfo: statusInfo)

            let word = userInfo!["word"] as! String
            let url = userInfo!["url"] as! String
            let (results, match) = Dict.shared.search(word, limit: SettingsManager.shared.resultsLimit)
            page.dispatchMessageToScript(withName: OutgoingMessage.showResult.rawValue, userInfo:
                ["word": match ?? "", "url": url, "result": results.map { $0.toJSON() }]
            )
        }

        if messageName == IncomingMessage.queryStatus.rawValue {
            page.dispatchMessageToScript(withName: OutgoingMessage.status.rawValue, userInfo: statusInfo)
        }
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        validationHandler(true, "")
        refreshToolbarIcon(in: window)
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        SettingsManager.shared.isLookupEnabled.toggle()
        refreshToolbarIcon(in: window)
    }
    
    private static let enabledIcon = NSImage(named: "ToolbarItemIcon.pdf")!
    private static let disabledIcon = NSImage(named: "ToolbarItemIconDisabled.pdf")!

    private func refreshToolbarIcon(in window: SFSafariWindow) {
        window.getToolbarItem { toolbarItem in
            toolbarItem?.setImage(SettingsManager.shared.isLookupEnabled ? Self.enabledIcon : Self.disabledIcon)
        }
    }
}
