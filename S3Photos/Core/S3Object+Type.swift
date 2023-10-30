//
//  S3Object+Type.swift
//  S3Photos
//
//  Created by Leon Li on 2023/10/16.
//

import Foundation

enum S3ObjectType {
    case group
    case photo
    case video
    case other
}

extension S3Object {
    var name: String? {
        key?.split(separator: "/").last.map(String.init)
    }

    var type: S3ObjectType {
        if key?.hasSuffix("/") == true {
            return .group
        }

        let ext = (key as NSString?)?.pathExtension.lowercased()
        switch ext {
        case "heic", 
             "jpg",
             "png":
            return .photo
        case "avi",
             "mov",
             "mp4":
            return .video
        default:
            return .other
        }
    }
}
