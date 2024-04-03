//
//  ViewController.swift
//  FileDirectory
//
//  Created by 김현구 on 3/28/24.
//

import UIKit
import PhotosUI
import UniformTypeIdentifiers

class ViewController: UIViewController {
    
    @IBOutlet weak var centerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onClickPhotoPicker(_ sender: Any) {
        PhotoPickerManager.shared.showPhotoPicker(vc: self)
    }

    @IBAction func onClickCreateFile(_ sender: Any) {
        FileService.shared.createDirectory("내 문서")
        FileService.shared.setFile("test.txt")
        let appendData = FileService.shared.stringToData("TEXT ")
        FileService.shared.append(data: appendData)
        if let readData = FileService.shared.read(),
           let readString = String(data: readData, encoding: .utf8) {
            Log.tag(.STORAGE).d(readString)
        }
    }
    
    @IBAction func onClickDocumentPicker(_ sender: Any) {
        DocumentPickerManager.shared.showDocumentPicker(vc: self)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        PhotoPickerManager.shared.picker(picker, didFinishPicking: results, view: centerView, vc: self)
    }
}

// MARK: - UIDocumentPickerDelegate
extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        DocumentPickerManager.shared.documentPicker(controller, didPickDocumentsAt: urls)
    }
}
