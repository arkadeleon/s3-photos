//
//  S3ObjectCache.swift
//  S3Photos
//
//  Created by Leon Li on 2023/10/16.
//

import Foundation
import UIKit

class S3ObjectCache {

    let account: S3Account

    private let thumbnailCache = NSCache<NSString, UIImage>()

    private let diskCacheURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

    init(account: S3Account) {
        self.account = account
    }

    func data(for object: S3Object) -> Data? {
        guard let eTag = object.eTag?.trimmingCharacters(in: CharacterSet(["\""])) else {
            return nil
        }

        let url = diskCacheURL.appending(path: "\(eTag).s3obj")
        let data = try? Data(contentsOf: url)

        return data
    }

    func setData(_ data: Data, forObject object: S3Object) {
        guard let eTag = object.eTag?.trimmingCharacters(in: CharacterSet(["\""])) else {
            return
        }

        let url = diskCacheURL.appending(path: "\(eTag).s3obj")
        try? data.write(to: url, options: .atomic)
    }

    func thumbnail(for object: S3Object) -> UIImage? {
        guard let eTag = object.eTag?.trimmingCharacters(in: CharacterSet(["\""])) else {
            return nil
        }

        var thumbnail: UIImage? = nil

        thumbnail = thumbnailCache.object(forKey: eTag as NSString)

        if thumbnail == nil {
            let url = diskCacheURL.appending(path: "\(eTag).s3objthumb")
            let data = try? Data(contentsOf: url)
            thumbnail = data.flatMap(UIImage.init)
        }

        return thumbnail
    }

    func setThumbnail(_ thumbnail: UIImage, forObject object: S3Object) {
        guard let eTag = object.eTag?.trimmingCharacters(in: CharacterSet(["\""])) else {
            return
        }

        thumbnailCache.setObject(thumbnail, forKey: eTag as NSString)

        let url = diskCacheURL.appending(path: "\(eTag).s3objthumb")
        let data = thumbnail.jpegData(compressionQuality: 1)
        try? data?.write(to: url, options: .atomic)
    }
}
