//
//  ViewController.swift
//  FileDirectory
//
//  Created by 김현구 on 3/28/24.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    @IBOutlet weak var centerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func onClickPhoto(_ sender: Any) {
        PhotoPickerManager.shared.showPhotoPicker(vc: self)
    }
    @IBAction func onClickFile(_ sender: Any) {
        FileService.shared.createDirectory("내 문서")
        FileService.shared.setFile("test.txt")
        let appendData = FileService.shared.stringToData("TEXT ")
        FileService.shared.append(data: appendData)
        if let readData = FileService.shared.read(),
           let readString = String(data: readData, encoding: .utf8) {
            Log.tag(.STORAGE).d(readString)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        PhotoPickerManager.shared.picker(picker, didFinishPicking: results, view: centerView, vc: self)
    }
}

