//
//  FileModel.swift
//  FileDirectory
//
//  Created by 김현구 on 3/28/24.
//

import Foundation
import PhotosUI


// MARK: - FileModel
struct FileModel {
    
    let data: Data
    let path: URL
    
    private init(data: Data, path: URL) {
        self.data = data
        self.path = path
    }

    static func createCompletionParam(result: PHPickerResult, _ completion: @escaping (FileModel?) -> Void) {
        guard let identifier = result.assetIdentifier,
              let fetchResult = self.getFetchResult(identifier: identifier),
              let asset = fetchResult.firstObject else {
            completion(nil)
            return
        }
        
        let itemProvider = result.itemProvider
        
        if (itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier)) {
            imageToFileModel(asset, itemProvider, completion)
        } else if (itemProvider.hasItemConformingToTypeIdentifier(UTType.video.identifier) ||
                   itemProvider.hasItemConformingToTypeIdentifier(UTType.appleProtectedMPEG4Video.identifier) ||
                   itemProvider.hasItemConformingToTypeIdentifier(UTType.quickTimeMovie.identifier)) {
            videoToFileModel(asset, completion)
        } else if (itemProvider.hasItemConformingToTypeIdentifier(UTType.livePhoto.identifier)) {
            completion(nil)
        } else {
            completion(nil)
        }
    }
}

// MARK: - Image
extension FileModel {
    private static func getFetchResult(identifier: String) -> PHFetchResult<PHAsset>? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: fetchOptions)
        return fetchResult
    }
    
    private static func imageToFileModel(_ asset: PHAsset, _ itemProvider: NSItemProvider, _ completion: @escaping (FileModel?) -> Void) {
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        option.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: option, resultHandler: { (imageData, dataUTI, orientation, info) in
            guard let UTI = dataUTI, let data = imageData else {
                completion(nil)
                return
            }
            
            itemProvider.loadFileRepresentation(forTypeIdentifier: UTI, completionHandler: { (url, error) in
                guard let filePath = url else {
                    completion(nil)
                    return
                }
                
                completion(FileModel(data: data, path: filePath))
            })
        })
    }
}

// MARK: - Video
extension FileModel {
    private static func videoToFileModel(_ asset: PHAsset, _ completion: @escaping (FileModel?) -> Void) {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .highQualityFormat
        PHImageManager.default().requestAVAsset(forVideo: asset, options: option) { (result, mix, info) in
            guard let avAsset = result as? AVURLAsset,
                  let data = try? Data(contentsOf: avAsset.url) else {
                completion(nil)
                return
            }
            
            completion(FileModel(data: data, path: avAsset.url))
        }
    }
}

// MARK: - property
extension FileModel {
    var size: String {
        let fileSize = data.count
        if fileSize < 1023 {
            return String(format: "%lu bytes", CUnsignedLong(fileSize))
        }
        var floatSize = Float(fileSize / 1024)
        if floatSize < 1023 {
            return String(format: "%.1f KB", floatSize)
        }
        floatSize = floatSize / 1024
        if floatSize < 1023 {
            return String(format: "%.1f MB", floatSize)
        }
        floatSize = floatSize / 1024
        return String(format: "%.1f GB", floatSize)
    }
}
