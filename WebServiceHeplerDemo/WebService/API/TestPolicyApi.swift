

import Foundation
import Moya



enum TestRequestType {
    case baidu
    case upload([LXUploadFileInfo],[String: Any]? = nil)
    case cityTest
}

extension TestRequestType: LXMoyaTargetType {
    var parameters: [String : Any] {
        switch self {
        case .baidu:
            return ["username": "postman", "password": "123465"]
        case let .upload(_, params):
            return params ?? [:]
        case .cityTest:
            return [:]
        }
    }
    
    var uploadFiles: [LXUploadFileInfo]? {
        switch self {
        case let .upload(files, _):
            return files
        default:
            return nil
        }
    }
    
    
    var method: Moya.Method {
        switch self {
        case .baidu:
            return .post
        case let .upload(_, params):
            return .post
        case .cityTest:
            return .get
        }
    }
    
    
    var baseURL : URL {
        switch self {
        case .baidu:
            return URL(string: apiHost)!
        case let .upload(_, params):
            return URL(string: cityHost)!
        case .cityTest:
            return URL(string: cityHost)!
        }
        
    }
}
