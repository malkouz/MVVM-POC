//
//  AttachmentModel.swift
//
//  Created by Moayad Al kouz on 2/20/19.
//  Copyright © 2019 Moayad Al kouz. All rights reserved.
//

import Foundation

enum AttachmentExtension:String {
    case doc
    case docx
    case mp3
    case xls
    case xlsx
    case ppt
    case pptx
    case pdf
    case zip
    case png
    case jpg
    case jpeg
    case mp4
    case wmv
    case other
}

struct AttachmentModel{
    var data:Data
    var fileName:String
    var pathExtension:AttachmentExtension
    var filesSize:String
    
    var mimeType: String{
        
        var b: UInt8 = 0
        data.copyBytes(to: &b, count: 1)
        
        switch b {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x4D, 0x49:
            return "image/tiff"
        case 0x25:
            return "application/pdf"
        case 0xD0:
            return "application/vnd"
        case 0x46:
            return "text/plain"
        default:
            return "application/octet-stream"
        }
    }
}
