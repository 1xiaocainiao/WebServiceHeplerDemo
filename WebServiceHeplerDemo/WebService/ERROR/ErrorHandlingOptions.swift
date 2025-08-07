//
//  ErrorHandlingOptions.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import Foundation
import Moya

struct ErrorHandlingOptions: OptionSet {
    let rawValue: Int
    
    static let toast = ErrorHandlingOptions(rawValue: 1 << 0)
    /// 默认一个按钮的alert
    static let defaultAlert = ErrorHandlingOptions(rawValue: 1 << 1)
    /// 自定义事件的alert
    static let alertWithAction = ErrorHandlingOptions(rawValue: 1 << 2)
    /// 自己在请求回调处理
    static let manual = ErrorHandlingOptions(rawValue: 1 << 3)
    /// 静默
    static let silent = ErrorHandlingOptions(rawValue: 1 << 4)
    
    static let `default`: ErrorHandlingOptions = [.toast]
}

struct RequestContext {
    let target: LXMoyaTargetType?
    var handlingOptions: ErrorHandlingOptions
    var sourcePage: String?
    /// 自己处理alert点击
    var alertActions: [UIAlertAction]?
    
    init(target: LXMoyaTargetType? = nil,
        options: ErrorHandlingOptions = .default,
         source: String? = nil,
         alertActions: [UIAlertAction]? = nil) {
        self.target = target
        self.handlingOptions = options
        self.sourcePage = source
        self.alertActions = alertActions
        if options == .defaultAlert {
            self.alertActions = nil
        }
    }
}
