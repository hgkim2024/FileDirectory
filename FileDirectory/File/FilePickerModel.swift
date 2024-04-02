//
//  FileModel.swift
//  FileDirectory
//
//  Created by 김현구 on 3/28/24.
//

import Foundation
import PhotosUI


// MARK: - FileModel
struct FilePickerModel {
    
    let data: Data
    let path: URL
    
    private init(data: Data, path: URL) {
        self.data = data
        self.path = path
    }
}

enum FileExt: String {
    case GIF
    case IMAGE
    case NONE
    
    static func fromExt(ext: String) -> FileExt {
        switch ext.lowercased() {
        case ".gif":
            return .GIF
        case ".png", ".jpeg", ".jpg":
            return .IMAGE
        default:
            return .NONE
        }
    }
}

// MARK: - Image
extension FilePickerModel {
    static func imageToFileModel(_ asset: PHAsset, _ itemProvider: NSItemProvider, _ completion: @escaping (FilePickerModel?) -> Void) {
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
                let model = FilePickerModel(data: data, path: filePath)
                Log.tag(.PHOTO).tag(.PATH).d("path: \(model.path)")
                Log.tag(.PHOTO).tag(.SIZE).d("size: \(model.size)")
                Log.tag(.PHOTO).tag(.EXT).d("ext: \(model.ext)")
                
                completion(model)
            })
        })
    }
}

// MARK: - Video
extension FilePickerModel {
    static func videoToFileModel(_ asset: PHAsset, _ completion: @escaping (FilePickerModel?) -> Void) {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .highQualityFormat
        PHImageManager.default().requestAVAsset(forVideo: asset, options: option) { (result, mix, info) in
            guard let avAsset = result as? AVURLAsset,
                  let data = try? Data(contentsOf: avAsset.url) else {
                completion(nil)
                return
            }
            
            let model = FilePickerModel(data: data, path: avAsset.url)
            Log.tag(.VIDEO).tag(.PATH).d("path: \(model.path)")
            Log.tag(.VIDEO).tag(.SIZE).d("size: \(model.size)")
            Log.tag(.VIDEO).tag(.EXT).d("ext: \(model.ext)")
            
            completion(model)
        }
    }
}

// MARK: - property
extension FilePickerModel {
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
    
    var ext: FileExt {
        let path = path.absoluteString
        if let lastCommaIdx = path.lastIndex(of: ".") {
            let ext = String(path[lastCommaIdx...])
            return FileExt.fromExt(ext: ext)
        }
        
        return .NONE
    }
}
