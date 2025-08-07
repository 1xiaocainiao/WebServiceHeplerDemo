//
//  ErrorHandlingOptions.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import Foundation
import Moya

enum ErrorHandlingOption: Int {
    case toast, defaultAlert, alertWithAction, manual, silent
    
    static let `default`: ErrorHandlingOption = .toast
}

struct RequestContext {
    let target: LXMoyaTargetType?
    var handlingOption: ErrorHandlingOption
    var sourcePage: String?
    /// 自己处理alert点击
    var alertActions: [UIAlertAction]?
    
    init(target: LXMoyaTargetType? = nil,
        option: ErrorHandlingOption = .default,
         source: String? = nil,
         alertActions: [UIAlertAction]? = nil) {
        self.target = target
        self.handlingOption = option
        self.sourcePage = source
        self.alertActions = alertActions
        if option == .defaultAlert {
            self.alertActions = nil
        }
    }
}
