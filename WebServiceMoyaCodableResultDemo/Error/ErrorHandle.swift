//
//  ErrorHandle.swift
//  PeiWan
//
//  Created by mac on 2024/10/29.
//

import Foundation

/// 后端定义好了返回的error  message国际化，前端只需要直接弹就行了，这里只定义了特殊需要处理的code，比如token过期

enum ResponseErrorCode: Int {
    case unknown = -1
    
    case tokenInvalid = 100
    case tokenExpired = 101
}
 
enum ToastType {
    case none
    
    case toast
    
    case alert
}

class ErrorHandle {
    static func handleError(_ error: Error?,
                                 autoLogoutHandler: LXWebServiceHelper.AutoLogOutHandler? = nil,
                                 toastHandler: LXWebServiceHelper.ToastHandler? = nil) {
//        guard let error = error as? LXError else { return }
//        switch error.errorCode {
//        case .tokenInvalid,
//                .tokenExpired:
//            printl(message: "token expired")
//            
//            SVProgressHUD.safeDismiss()
//            
//            autoLogoutHandler?()
//            
//            AppDelegate.app?.enterLogin()
//        default:
//            let errorMessage: String = error.message ?? LXLocalizedString("UnknownError")
//            
//            guard let result = toastHandler?(error) else {
//                return
//            }
//            
//            if result.autoShow {
//                switch result.type {
//                case .toast:
//                    SVProgressHUD.showError(withStatus: errorMessage)
//                case .alert:
//                    printl(message: "show error alert")
//                case .none:
//                    break
//                }
//            } else {
//                printl(message: "自己处理错误")
//            }
//            break
//        }
    }
}
