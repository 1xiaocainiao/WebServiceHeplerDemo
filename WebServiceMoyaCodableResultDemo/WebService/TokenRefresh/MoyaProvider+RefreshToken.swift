//
//  MoyaProviderEX.swift
//  WebServiceMoyaCodableResultDemo
//
//  Created by mac on 2024/10/21.
//

/// 这个实际使用过，支持并发

import Foundation
import Moya

extension MoyaProvider {
    // 刷新token的设置
    static func endpointResolver() -> MoyaProvider<Target>.RequestClosure {
        return { (endpoint, closure) in
            var request = try! endpoint.urlRequest()
            request.timeoutInterval = 30
            
            TokenRefreshManager.shared.executeWithRefreshToken {
                // 必须更新header
//                if let token = LoginResultModel.currentInfo()?.token {
//                    request.setValue(token, forHTTPHeaderField: "Authorization")
//                }
                
                closure(.success(request))
            }
        }
    }
}


