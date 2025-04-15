//
//  LXError.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import Foundation
import Moya

public enum LXError: Error, Equatable {
    // json 解析失败
    case jsonSerializationFailed(message: String)
    // 服务器返回错误
    case serverResponseError(message: String?, code: Int)
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
    // 服务器连接失败
    case serverConnectionFailed
    // 取消请求
    case cancelledRequest
}

extension LXError {
    var message: String? {
        switch self {
        case let .serverResponseError(message: msg, code: _):
            return msg
        case .networkConnectFailed:
            return "net_connect_error"
        case .networkConnectTimeOut:
            return "net_connect_timeout_error"
        case .jsonSerializationFailed(message: _),
                .serverDataFormatError,
                .missStatuCode,
                .missDataContent,
                .dataContentTransformToModelFailed:
            return "net_parse_error"
        case .serverConnectionFailed:
            return "service_error"
        case .exception(message: let message):
            return message
        case .cancelledRequest:
            return "cancel_request"
        }
    }
    
    var code: Int {
        switch self {
        case let .serverResponseError(message: _, code: code):
            return code
        default:
            return -1
        }
    }
    
    var errorCode: ResponseErrorCode {
        switch self {
        case let .serverResponseError(message: _, code: code):
            return ResponseErrorCode(rawValue: code) ?? .unknown
        default:
            return .unknown
        }
    }
}

extension MoyaError {
    func asLXError() -> LXError {
        switch self {
        case .statusCode(let response):
            return .serverResponseError(message: String(data: response.data, encoding: .utf8),
                                        code: response.statusCode)
        case .imageMapping,
                .jsonMapping,
                .stringMapping,
                .objectMapping:
            return LXError.jsonSerializationFailed(message: "数据解析失败")
        case .underlying(let error, _):
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet:
                    printl(message: "网络不可用，请检查连接")
                    return LXError.networkConnectFailed
                case NSURLErrorTimedOut:
                    printl(message: "请求超时")
                    return LXError.networkConnectTimeOut
                case NSURLErrorCannotConnectToHost:
                    printl(message: "无法连接到服务器")
                    return LXError.serverConnectionFailed
                case NSURLErrorSecureConnectionFailed:
                    printl(message: "安全连接失败")
                    return LXError.networkConnectFailed
                case NSURLErrorCancelled:
                    printl(message: "取消请求")
                    return LXError.cancelledRequest
                default:
                    return .exception(message: "网络错误: \(nsError.localizedDescription)")
                }
            }
            return .exception(message: "未知错误: \(error.localizedDescription)")
        default:
            return .exception(message: self.localizedDescription)
        }
    }
}
