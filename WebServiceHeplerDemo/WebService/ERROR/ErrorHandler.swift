//
//  ErrorHandler.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import Foundation
import SVProgressHUD

protocol ErrorHandler: AnyObject {
    static func handle(error: LXError, context: RequestContext)
}

final class DefaultErrorHandler: ErrorHandler {
    static func handle(error: LXError, context: RequestContext) {
        if checkForceLogout(error: error) {
            return
        }
        
        guard !context.handlingOptions.contains(.manual) else { return }
        let message = error.message ?? "Unknown"
        let options = context.handlingOptions
        
        // 优先级处理链
        if let customHandler = context.customHandler {
            // 1. 优先使用调用方提供的闭包
            customHandler(error)
        } else if options.contains(.forceAlert) {
            // 2. 强制 Alert 模式
            showAlert(message: message)
        } else if options.contains(.forceToast) {
            // 3. 强制 Toast 模式
            showToast(message: message)
        } else if context.handlingOptions.contains(.silent) {
            printl(message: "不需要处理，只需要log")
        } else {
            showToast(message: message)
        }
    }
    
    static fileprivate func showAlert(message: String) {
        printl(message: "显示系统弹窗: \(message)")
    }
    
    static fileprivate func showToast(message: String) {
        printl(message: "显示 Toast 提示: \(message)")
        SVProgressHUD.showError(withStatus: message)
    }
    
    static func checkForceLogout(error: LXError) -> Bool {
        switch error.errorCode {
        case .tokenInvalid:
            printl(message: "强制退出登录")
            return true
        default:
            return false
        }
    }
}
