//
//  DocumentPickerManager.swift
//  FileDirectory
//
//  Created by 김현구 on 4/3/24.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

class DocumentPickerManager {
    static let shared = DocumentPickerManager()
    private init() { }
    
    
    func showDocumentPicker(vc: UIViewController) {
        let documentPicker: UIDocumentPickerViewController

        if #available(iOS 14.0, *) {
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        } else {
            documentPicker = UIDocumentPickerViewController(documentTypes: contentTypes.map({$0.identifier}), in: .import)
        }
       
       documentPicker.delegate = vc as? UIDocumentPickerDelegate
       documentPicker.allowsMultipleSelection = false
       documentPicker.modalPresentationStyle = .fullScreen
       vc.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileUrl = urls.first else { return }
        
    }
}

// MARK: - contentTypes
extension DocumentPickerManager {
    var contentTypes: [UTType] {
        let types : [UTType] =
            [.item,
             .content,
             .compositeContent,
             .diskImage,
             .data,
             .directory,
             .resolvable,
             .symbolicLink,
             .executable,
             .mountPoint,
             .aliasFile,
             .urlBookmarkData,
             .url,
             .fileURL,
             .text,
             .plainText,
             .utf8PlainText,
             .utf16ExternalPlainText,
             .utf16PlainText,
             .delimitedText,
             .commaSeparatedText,
             .tabSeparatedText,
             .utf8TabSeparatedText,
             .rtf,
             .html,
             .xml,
             .yaml,
             .sourceCode,
             .assemblyLanguageSource,
             .cSource,
             .objectiveCSource,
             .swiftSource,
             .cPlusPlusSource,
             .objectiveCPlusPlusSource,
             .cHeader,
             .cPlusPlusHeader]

        let types_1: [UTType] =
            [.script,
             .appleScript,
             .osaScript,
             .osaScriptBundle,
             .javaScript,
             .shellScript,
             .perlScript,
             .pythonScript,
             .rubyScript,
             .phpScript,
             .makefile, //'makefile' is only available in iOS 15.0 or newer
             .json,
             .propertyList,
             .xmlPropertyList,
             .binaryPropertyList,
             .pdf,
             .rtfd,
             .flatRTFD,
             .webArchive,
             .image,
             .jpeg,
             .tiff,
             .gif,
             .png,
             .icns,
             .bmp,
             .ico,
             .rawImage,
             .svg,
             .livePhoto,
             .heif,
             .heic,
             .webP,
             .threeDContent,
             .usd,
             .usdz,
             .realityFile,
             .sceneKitScene,
             .arReferenceObject,
             .audiovisualContent]

        let types_2: [UTType] =
            [.movie,
             .video,
             .audio,
             .quickTimeMovie,
             UTType("com.apple.quicktime-image"),
             .mpeg,
             .mpeg2Video,
             .mpeg2TransportStream,
             .mp3,
             .mpeg4Movie,
             .mpeg4Audio,
             .appleProtectedMPEG4Audio,
             .appleProtectedMPEG4Video,
             .avi,
             .aiff,
             .wav,
             .midi,
             .playlist,
             .m3uPlaylist,
             .folder,
             .volume,
             .package,
             .bundle,
             .pluginBundle,
             .spotlightImporter,
             .quickLookGenerator,
             .xpcService,
             .framework,
             .application,
             .applicationBundle,
             .applicationExtension,
             .unixExecutable,
             .exe,
             .systemPreferencesPane,
             .archive,
             .gzip,
             .bz2,
             .zip,
             .appleArchive,
             .spreadsheet,
             .presentation,
             .database,
             .message,
             .contact,
             .vCard,
             .toDoItem,
             .calendarEvent,
             .emailMessage,
             .internetLocation,
             .internetShortcut,
             .font,
             .bookmark,
             .pkcs12,
             .x509Certificate,
             .epub,
             .log]
                .compactMap({ $0 })

        return types + types_1 + types_2
    }
}
