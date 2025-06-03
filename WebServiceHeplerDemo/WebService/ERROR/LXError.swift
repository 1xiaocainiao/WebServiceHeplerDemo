//
//  LXError.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import Foundation
import Moya
import Alamofire

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
            return handleMoyaUnderlyingNetworkError(error)
        default:
            return .exception(message: self.localizedDescription)
        }
    }
    
    func handleMoyaUnderlyingNetworkError(_ error: Error) -> LXError {
        // 优先处理 Alamofire 特定错误
        if let afError = error as? AFError {
            switch afError {
            case .sessionTaskFailed(let underlying):
                if let urlError = underlying as? URLError {
                    return handleURLError(urlError)
                } else {
                    return .exception(message: self.localizedDescription)
                }
            case .explicitlyCancelled:
                printl(message: "取消请求")
                return LXError.cancelledRequest
            default:
                printl(message: "Alamofire 错误: \(afError)")
                return .exception(message: self.localizedDescription)
            }
        }
        
        // 处理系统 URL 错误
        if let urlError = error as? URLError {
            return handleURLError(urlError)
        }
        
        printl(message: "未知错误类型: \(self.localizedDescription)")
        return .exception(message: self.localizedDescription)
    }
    
    private func handleURLError(_ error: URLError) -> LXError {
        switch error.code {
        case .cancelled:
            printl(message: "取消请求")
            return LXError.cancelledRequest
        case .timedOut:
            printl(message: "请求超时")
            return LXError.networkConnectTimeOut
        case .notConnectedToInternet:
            printl(message: "网络不可用，请检查连接")
            return LXError.networkConnectFailed
        case .networkConnectionLost,
                .cannotFindHost,
                .cannotConnectToHost:
            printl(message: "无法连接到服务器")
            return LXError.serverConnectionFailed
        case .secureConnectionFailed:
            printl(message: "安全连接失败")
            return LXError.networkConnectFailed
        default:
            return .exception(message: self.localizedDescription)
        }
    }
}
