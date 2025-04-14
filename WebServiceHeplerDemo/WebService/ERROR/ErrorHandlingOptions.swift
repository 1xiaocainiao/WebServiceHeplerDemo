//
//  ErrorHandlingOptions.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import Foundation

struct ErrorHandlingOptions: OptionSet {
    let rawValue: Int
    // 目前auto 默认处理的toast
    static let auto = ErrorHandlingOptions(rawValue: 1 << 0)
    static let manual = ErrorHandlingOptions(rawValue: 1 << 1)
    static let forceToast = ErrorHandlingOptions(rawValue: 1 << 2)
    static let forceAlert = ErrorHandlingOptions(rawValue: 1 << 3)
    static let silent = ErrorHandlingOptions(rawValue: 1 << 4)
    
    static let `default`: ErrorHandlingOptions = [.auto]
}

struct RequestContext {
    var handlingOptions: ErrorHandlingOptions
    var sourcePage: String?
    var customHandler: ((LXError) -> Void)?
    
    init(options: ErrorHandlingOptions = .default,
         source: String? = nil,
         handler: ((LXError) -> Void)? = nil) {
        self.handlingOptions = options
        self.sourcePage = source
        self.customHandler = handler
    }
}
