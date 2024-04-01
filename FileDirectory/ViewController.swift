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
        PhotoPickerManager.sharedInstance.showPhotoPicker(vc: self)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        PhotoPickerManager.sharedInstance.picker(picker, didFinishPicking: results, view: centerView)
    }
}

