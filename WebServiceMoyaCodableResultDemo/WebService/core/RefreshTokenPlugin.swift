//
//  RefreshTokenPlugin.swift
//  WebServiceMoyaCodableResultDemo
//
//  Created by mac on 2024/10/21.
//


/// 刷新token的另一种实现，在请求前判断token是否过期

import Foundation
import Moya

//public class RefreshTokenPlugin: PluginType {
//    
//    public init() {
//        
//    }
//    
//    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
//        
//        printl(message: "prepare request")
//        
//        guard let authorizable = target as? AccessTokenAuthorizable,
//              let authorizationType = authorizable.authorizationType else {
//            
//            return request
//        }
//        
//        RefreshTokenManager.default.checkAndRefreshTokenIfNeeded { finish in
//            printl(message: "refresh token finish")
//        }
//        
//        var request = request
//        let authValue = authorizationType.value + " " + RefreshTokenManager.default.token
//        request.addValue(authValue, forHTTPHeaderField: "Authorization")
//        
//        printl(message: "prepare request finish")
//
//        return request
//    }
//    
//}

// 另一种写法

//public class RefreshTokenPlugin: PluginType {
//    
//    private var semaphore = DispatchSemaphore(value: 0)
//    
//    private var isRefreshing = false
//    
//    public init() {
//        
//    }
//    
//    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
//        
//        NSLog("prepare request", "")
//        
//        guard let authorizable = target as? AccessTokenAuthorizable,
//              let authorizationType = authorizable.authorizationType else {
//            
//            return request
//        }
//        
//        let now = Date().timeIntervalSince1970
//        
//        // if less than 1 hour, refresh token.
//        if (TokenManager.shared.expiredTimestamp - now) < 3600, let refreshToke = TokenManager.shared.refreshToken  {
//            
//            if !isRefreshing {
//                isRefreshing = true
//                
//                NSLog("start refresh token automatic", "")
//                
//                let provider = MoyaProvider<SRAccountApi>()
//                
//                // refresh token once
//                provider.request(.refreshToken(refreshToken: refreshToke), callbackQueue: DispatchQueue.global()) { result in
//                    
//                    defer {
//                        isRefreshing = false
//                        
//                        self.semaphore.signal()
//                    }
//                    
//                    do {
//
//                        let response = try result.get()
//                        let value = try response.mapJSON() as? [String: Any]
//
//                        if let code = value?["code"] as? String,
//                           let message = value?["message"] as? String,
//                           code == "10001",
//                           let data = value?["data"] as? [String: Any],
//                           let authorization = data["authorization"] as? [String: Any] {
//
//                            print("refresh token successful! \(code) \(message) \(data)")
//                            
//                            // Update tokens and expired timestamp.
//                            TokenManager.shared.accessToken = authorization["accessToken"] as? String ?? ""
//                            TokenManager.shared.refreshToken = authorization["refreshToken"] as? String
//                            TokenManager.shared.expiredTimestamp = (authorization["expiredTimestamp"] as? TimeInterval ?? 0) / 1000
//                            
//                        } else {
//                            
//                            print("refresh token failed!")
//                            TokenManager.shared.refreshToken = nil
//                        }
//
//                    } catch {
//
//                        NSLog("error %@", error.localizedDescription)
//                        TokenManager.shared.refreshToken = nil
//                    }
//                }
//            }
//            
//            semaphore.wait()
//        }
//        
//        var request = request
//        let authValue = authorizationType.value + " " + TokenManager.shared.accessToken
//        request.addValue(authValue, forHTTPHeaderField: "Authorization")
//
//        return request
//    }
//    
//}
