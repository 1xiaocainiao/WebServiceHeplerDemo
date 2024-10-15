

import Foundation

public enum LXFileType {
    case image
    case video
    case other
}

public struct LXUploadFileInfo {
    public var filePath: String
    public var fileName: String
    public var fileLength: String
    public var fileUploadKey: String
    public var fileType: LXFileType
    
    init(path: String,
         fileName: String,
         length: String = "0",
         uploadKey: String,
         fileType: LXFileType = LXFileType.image) {
        self.filePath = path
        self.fileName = fileName
        self.fileLength = length
        self.fileUploadKey = uploadKey
        self.fileType = fileType
    }
}
