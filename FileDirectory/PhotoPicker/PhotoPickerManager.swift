//
//  FileManager.swift
//  FileDirectory
//
//  Created by 김현구 on 3/28/24.
//

import Foundation
import Photos
import PhotosUI
import UIKit
import AVKit
import ImageIO
import common

class PhotoPickerManager {
    static let shared = PhotoPickerManager()
    private init() { }
    
    private var fileModel: PhotoPickerModel? = nil
    var looper : AVPlayerLooper? = nil
    
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
    
    func showPhotoPicker(vc: UIViewController) {
        photoAuth() {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.preferredAssetRepresentationMode = .current
            config.selection = .ordered
            config.selectionLimit = 1
//            let newFilter = PHPickerFilter.any(of: [.images, .videos, .livePhotos, .])
//            config.filter = newFilter
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = vc as? PHPickerViewControllerDelegate
            
            vc.present(picker, animated: true)
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult], view: UIView, vc: UIViewController) {
        guard let result = results.first,
            let identifier = result.assetIdentifier,
              let fetchResult = getFetchResult(identifier: identifier),
              let asset = fetchResult.firstObject else {
            picker.dismiss(animated: true)
            return
        }
        
        view.subviews.forEach { $0.removeFromSuperview() }
        Log.tag(.PHOTO).tag(.PICKER).tag(.MEDIA).d("media: \(asset.mediaType), source: \(asset.sourceType)")
        
        let prov = result.itemProvider
        
        for id in prov.registeredTypeIdentifiers {
            Log.tag(.PHOTO).tag(.PICKER).tag(.MEDIA).tag(.ID).d(id)
        }
        
        if (prov.hasItemConformingToTypeIdentifier(UTType.gif.identifier)) {
            // TODO: - GIF 개발
//            settingVideo(itemProvider: prov, view: view, vc: vc, fileModel: nil)
        } else if (prov.hasItemConformingToTypeIdentifier(UTType.image.identifier)) {
            PhotoPickerModel.imageToFileModel(asset, prov) { [weak self] fileModel in
                guard let `self` = self else { return }
                self.setFileModel(fileModel: fileModel)
                self.settingImage(itemProvider: prov, view: view)
            }
            
        } else if (prov.hasItemConformingToTypeIdentifier(UTType.video.identifier) ||
                   prov.hasItemConformingToTypeIdentifier(UTType.appleProtectedMPEG4Video.identifier) ||
                   prov.hasItemConformingToTypeIdentifier(UTType.quickTimeMovie.identifier)) {
            PhotoPickerModel.videoToFileModel(asset) { [weak self] fileModel in
                guard let `self` = self else { return }
                self.setFileModel(fileModel: fileModel)
                self.settingVideo(itemProvider: prov, view: view, vc: vc)
            }
        } else if (prov.hasItemConformingToTypeIdentifier(UTType.livePhoto.identifier)) {
            // : Live Photo
        } else {
            // : etc ...
        }
        
        DispatchQueue.main.async {
            picker.dismiss(animated: true)
        }
    }
    
    private func setFileModel(fileModel: PhotoPickerModel?) {
        self.fileModel = fileModel
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
    
    private func settingVideo(itemProvider: NSItemProvider, view: UIView, vc: UIViewController) {
        let movie = UTType.movie.identifier
        
        itemProvider.loadFileRepresentation(forTypeIdentifier: movie) { url, err in
            if let url = url {
                DispatchQueue.main.sync {
                    let av = AVPlayerViewController()
                    let player = AVPlayer(url:url)
                    av.player = player
                    vc.addChild(av)
                    av.view.frame = view.bounds
                    av.view.backgroundColor = view.backgroundColor
                    view.addSubview(av.view)
                    av.didMove(toParent: vc)
                    player.play()
                }
            }
        }
    }
    
    private func getFetchResult(identifier: String) -> PHFetchResult<PHAsset>? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: fetchOptions)
        return fetchResult
    }
}
