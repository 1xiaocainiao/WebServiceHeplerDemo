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
        if let target = context.target {
            printl(message: "error request url: \(target.baseURL)")
            printl(message: "error request path: \(target.path)")
        }
        
        if checkForceLogout(error: error) {
            return
        }
        
        let options = context.handlingOption
        
        if options == .manual ||
            options == .silent {
            printl(message: "手动处理错误或者静默")
            return
        }
        
        let message = error.message ?? "Unknown"
        
        if options == .toast {
            showToast(message: message)
        }
        
        if options == .defaultAlert ||
            options == .alertWithAction {
            showAlert(message: message, actions: context.alertActions)
        }
    }
    
    static fileprivate func showAlert(message: String, actions: [UIAlertAction]? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        if let actions = actions, actions.isNotEmpty {
            // 有点击事件回调
            printl(message: "显示 Alert 多个action 提示: \(message)")
            
            for action in actions {
                alert.addAction(action)
            }
        } else {
            // 无点击事件回调
            printl(message: "显示 默认 Alert 提示: \(message)")
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            let alert = UIAlertController(title: "title", message: "message", preferredStyle: .alert)
            alert.addAction(cancelAction)
        }
        let root = UIApplication.shared.keyWindow?.rootViewController
        root?.present(alert, animated: true)
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
    
    static func checkShowError(_ error: Error?) {
        guard let error = error as? LXError else {
            SVProgressHUD.showError(withStatus: "UnknownError")
            return
        }
        SVProgressHUD.showError(withStatus: error.message)
    }
}
