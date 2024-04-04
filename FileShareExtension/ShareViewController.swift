//
//  ShareViewController.swift
//  FileShareExtension
//
//  Created by 김현구 on 4/4/24.
//

import UIKit
import Social
import MobileCoreServices
import common

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        Log.tag(.SHARE).tag(.RECEIVED).d("")
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
           let itemProvider = item.attachments?.first {
            Log.tag(.SHARE).tag(.RECEIVED).d("first")
        }
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
