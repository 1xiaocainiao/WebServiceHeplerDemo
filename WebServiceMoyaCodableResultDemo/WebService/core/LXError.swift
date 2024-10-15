

import Foundation

public enum LXError: Error {
    // json 解析失败
    case jsonSerializationFailed(message: String)
    // json转字典失败
    case jsonToDictionaryFailed(message: String)
    // 服务器返回错误
    case serverResponseError(message: String?, code: String)
    // 自定义错误
    case exception(message: String)
    // 服务器返回数据初始化失败
    case serverDataFormatError
    // statucode
    case missStatuCode
    // 缺失data数据
    case missDataContent
    // data转model失败
    case dataContentTransformToModelFailed
    // 网络请求失败
    case networkConnectFailed
    // 网络请求超时
    case networkConnectTimeOut
}

extension LXError {
    var message: String? {
        switch self {
        case let .serverResponseError(message: msg, code: _):
            return msg
        default:
            return nil
        }
    }
    
    var code: String {
        switch self {
        case let .serverResponseError(message: _, code: code):
            return code
        default:
            return "-1"
        }
    }
}
