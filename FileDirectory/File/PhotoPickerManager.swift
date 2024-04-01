//
//  FileManager.swift
//  FileDirectory
//
//  Created by 김현구 on 3/28/24.
//

import Foundation
import Photos
import PhotosUI

class PhotoPickerManager {
    static let sharedInstance = PhotoPickerManager()
    private init() { }
    
    private var fileModel: FileModel? = nil {
        didSet {
            if let fileModel = self.fileModel {
                NSLog("fileModel - path: \(fileModel.path)")
                NSLog("fileModel - data size: \(fileModel.size)")
            }
        }
    }
    
    private func photoAuth(_ completion: (() -> Void)? = nil) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { (status) in
            switch status {
            case .notDetermined:
                break
            case .restricted:
                NSLog("[@Photo] Photo Authorization - restricted")
                break
            case .denied:
                NSLog("[@Photo] Photo Authorization - denied")
                break
            case .authorized:
                NSLog("[@Photo] Photo Authorization - authorized")
                DispatchQueue.main.async {
                    completion?()
                }
                break
            case .limited:
                NSLog("[@Photo] Photo Authorization - limited")
                break
            default:
                break
            }
        })
    }
    
    func showPhotoPicker(vc: ViewController) {
        photoAuth() {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.preferredAssetRepresentationMode = .current
            config.selection = .ordered
            config.selectionLimit = 1
//            let newFilter = PHPickerFilter.any(of: [.images, .videos, .livePhotos, .])
//            config.filter = newFilter
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = vc
            
            vc.present(picker, animated: true)
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult], view: UIView) {
        guard let result = results.first else {
            picker.dismiss(animated: true)
            return
        }
        
        FileModel.createCompletionParam(result: result) { fileModel in
            self.fileModel = fileModel
        }
        
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let itemProvider = result.itemProvider
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.video.identifier) {
            // : Video
        } else if itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
            // : Live Photo
        } else if itemProvider.canLoadObject(ofClass: UIImage.self) {
            settingImage(itemProvider: itemProvider, view: view)
        }
        
        DispatchQueue.main.async {
            picker.dismiss(animated: true)
        }
    }
    
    private func settingImage(itemProvider: NSItemProvider, view: UIView) {
        itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
            guard let data = data,
                  let cgImageSource = CGImageSourceCreateWithData(data as CFData, nil),
                  let properties = CGImageSourceCopyPropertiesAtIndex(cgImageSource, 0, nil) else { return }
            
            let image = CGImageSourceCreateImageAtIndex(cgImageSource, 0, properties)!
            DispatchQueue.main.async {
                let uiImage = UIImage(cgImage: image)
                let iv = UIImageView(image: uiImage)
                iv.contentMode = .scaleAspectFit
                iv.frame = view.bounds
                view.addSubview(iv)
            }
        }
    }
}
