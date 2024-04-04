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
import UniformTypeIdentifiers
import Photos

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        Log.tag(.SHARE).tag(.RECEIVED).d("content size: \(contentText.count)")
        return true
    }

    override func didSelectPost() {
        Log.tag(.SHARE).tag(.RECEIVED).d("contentText: \(String(describing: contentText))")
        
        if let items = extensionContext?.inputItems as? [NSExtensionItem] {
            Log.tag(.SHARE).tag(.RECEIVED).d("item size: \(items.count)")
            for item in items {
                if let itemProvider = item.attachments?.first {
                    if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                        itemProvider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { (data, error) in
                            if error == nil, let url = data as? URL {
                                Log.tag(.SHARE).tag(.RECEIVED).tag(.PHOTO).d("path: \(url.path)")
                            }
                        }
                    }
                    
                    if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                        itemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { text, error in
                            if error == nil, let text = text as? String {
                                Log.tag(.SHARE).tag(.RECEIVED).tag(.TEXT).d("text: \(text)")
                            }
                        })
                    }
                }
            }
        }
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
