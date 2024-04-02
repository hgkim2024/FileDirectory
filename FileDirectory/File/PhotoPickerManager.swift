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
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult], view: UIView, vc: ViewController) {
        guard let result = results.first,
            let identifier = result.assetIdentifier,
              let fetchResult = getFetchResult(identifier: identifier),
              let asset = fetchResult.firstObject else {
            picker.dismiss(animated: true)
            return
        }
        
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let prov = result.itemProvider
        if (prov.hasItemConformingToTypeIdentifier(UTType.image.identifier)) {
            FileModel.imageToFileModel(asset, prov, setFileModel)
            settingImage(itemProvider: prov, view: view)
        } else if (prov.hasItemConformingToTypeIdentifier(UTType.video.identifier) ||
                   prov.hasItemConformingToTypeIdentifier(UTType.appleProtectedMPEG4Video.identifier) ||
                   prov.hasItemConformingToTypeIdentifier(UTType.quickTimeMovie.identifier)) {
            FileModel.videoToFileModel(asset, setFileModel)
            settingVideo(itemProvider: prov, view: view, vc: vc)
        } else if (prov.hasItemConformingToTypeIdentifier(UTType.livePhoto.identifier)) {
            // : Live Photo
        } else {
            // : etc ...
        }
        
        DispatchQueue.main.async {
            picker.dismiss(animated: true)
        }
    }
    
    private func setFileModel(fileModel: FileModel?) {
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
    
    private func settingVideo(itemProvider: NSItemProvider, view: UIView, vc: ViewController) {
        let movie = UTType.movie.identifier
        
        itemProvider.loadFileRepresentation(forTypeIdentifier: movie) { url, err in
            if let url = url {
                DispatchQueue.main.sync {
                    // TODO: - GIF 조건 문이 잘못됨 - File Path 로 구분하는 것이 제일 좋은 거 같다.
                    let loopType = "com.apple.private.auto-loop-gif"
                    if itemProvider.hasItemConformingToTypeIdentifier(loopType) {
                        let av = AVPlayerViewController()
                        let player = AVQueuePlayer(url:url)
                        av.player = player
                        vc.addChild(av)
                        self.looper = AVPlayerLooper(player: player, templateItem: player.currentItem!)
                        av.view.frame = view.bounds
                        av.view.backgroundColor = view.backgroundColor
                        view.addSubview(av.view)
                        av.didMove(toParent: vc)
                        player.play()
                    } else {
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
    }
    
    private func getFetchResult(identifier: String) -> PHFetchResult<PHAsset>? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: fetchOptions)
        return fetchResult
    }
}
