//
//  MoyaRefreshToken.swift
//  WebServiceMoyaCodableResultDemo
//
//  Created by mac on 2024/10/29.
//

import Foundation
import Moya

// Token 管理单例
//class TokenManager {
//    static let shared = TokenManager()
//    private init() {}
//
//    var accessToken: String?
//    var isRefreshing = false
//    var failedRequests: [(TargetType, (Result<Response, MoyaError>) -> Void)] = []
//
//    // 存储当前的 token
//    func setToken(_ token: String) {
//        accessToken = token
//    }
//
//    // 清除所有状态
//    func reset() {
//        isRefreshing = false
//
//        failedRequests.removeAll()
//    }
//}
//
//// Token 刷新插件
//class TokenRefreshPlugin: PluginType {
//    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
//        switch result {
//        case .success:
//            return result
//        case .failure(let error):
//            // 判断是否是 token 过期错误（根据实际 API 返回修改判断条件）
//            if case let .statusCode(response) = error, response.statusCode == 401 {
//                handleTokenRefresh(target: target, completion: { result in
//                    // 处理结果
//                })
//            }
//            return result
//        }
//    }
//
//    private func handleTokenRefresh(target: TargetType, completion: @escaping (Result<Response, MoyaError>) -> Void) {
//        let tokenManager = TokenManager.shared
//
//        // 如果已经在刷新中，将请求加入等待队列
//        if tokenManager.isRefreshing {
//            tokenManager.failedRequests.append((target, completion))
//            return
//        }
//
//        tokenManager.isRefreshing = true
//
//        // 调用刷新 token 的 API
//        refreshToken { result in
//            switch result {
//            case .success(let newToken):
//                tokenManager.setToken(newToken)
//                // 重试所有失败的请求
//                self.retryFailedRequests()
//            case .failure(let error):
//                // 处理刷新 token 失败的情况
//                tokenManager.failedRequests.forEach { $0.1(.failure(error)) }
//                tokenManager.reset()
//            }
//        }
//    }
//
//    private func retryFailedRequests() {
//        let tokenManager = TokenManager.shared
//        let requests = tokenManager.failedRequests
//
//        tokenManager.reset()
//
//        requests.forEach { target, completion in
//            // 使用新 token 重新发起请求
//            let provider = MoyaProvider<MultiTarget>()
//            let multiTarget = MultiTarget(target)
//            provider.request(multiTarget) { result in
//                completion(result)
//            }
//        }
//    }
//
//    // 刷新 token 的网络请求
//    private func refreshToken(completion: @escaping (Result<String, MoyaError>) -> Void) {
//        // 实现刷新 token 的具体逻辑
//        //        let provider = MoyaProvider<AuthAPI>()
//        //        provider.request(.refreshToken) { result in
//        //            switch result {
//        //            case .success(let response):
//        //                // 解析响应获取新 token
//        //                if let newToken = try? response.map(TokenResponse.self).token {
//        //                    completion(.success(newToken))
//        //                } else {
//        //                    completion(.failure(.jsonMapping(response)))
//        //                }
//        //            case .failure(let error):
//        //                completion(.failure(error))
//        //            }
//        //        }
//    }
//}

// Token 管理单例
class TokenManager {
    static let shared = TokenManager()
    private init() {}
    
    private let lock = NSLock() // 添加锁来保护共享资源
    private var _isRefreshing = false
    private var _accessToken: String?
    private var _failedRequests: [(TargetType, (Result<Response, MoyaError>) -> Void)] = []
    
    // 使用信号量来控制刷新token的并发
    let refreshSemaphore = DispatchSemaphore(value: 1)
    
    var accessToken: String? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _accessToken
        }
        set {
            lock.lock()
            _accessToken = newValue
            lock.unlock()
        }
    }
    
    var isRefreshing: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _isRefreshing
        }
        set {
            lock.lock()
            _isRefreshing = newValue
            lock.unlock()
        }
    }
    
    var failedRequests: [(TargetType, (Result<Response, MoyaError>) -> Void)] {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _failedRequests
        }
        set {
            lock.lock()
            _failedRequests = newValue
            lock.unlock()
        }
    }
    
    func appendFailedRequest(target: TargetType, completion: @escaping (Result<Response, MoyaError>) -> Void) {
        lock.lock()
        _failedRequests.append((target, completion))
        lock.unlock()
    }
    
    func reset() {
        lock.lock()
        _isRefreshing = false
        _failedRequests.removeAll()
        lock.unlock()
    }
}

// Token 刷新插件
class TokenRefreshPlugin: PluginType {
    private let queue = DispatchQueue(label: "com.app.tokenrefresh", attributes: .concurrent)
    
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch result {
        case .success:
            return result
        case .failure(let error):
            if case let .statusCode(response) = error, response.statusCode == 401 {
                // 使用信号量等待token刷新完成
                let semaphore = DispatchSemaphore(value: 0)
                var finalResult = result
                
                handleTokenRefresh(target: target) { _ in
                    
                } completion: {
                    semaphore.signal()
                }
                
                // 等待刷新完成
                _ = semaphore.wait(timeout: .now() + 30) // 设置超时时间
                return finalResult
            }
            return result
        }
    }
    
    private func handleTokenRefresh(target: TargetType,
                                    cache cacheCompletion: @escaping (Result<Response, MoyaError>) -> Void, completion: @escaping () -> Void) {
        let tokenManager = TokenManager.shared
        
        queue.async {
            // 使用信号量确保只有一个刷新token的请求
            tokenManager.refreshSemaphore.wait()
            
            if tokenManager.isRefreshing {
                tokenManager.appendFailedRequest(target: target, completion: cacheCompletion)
                tokenManager.refreshSemaphore.signal()
                return
            }
            
            tokenManager.isRefreshing = true
            tokenManager.refreshSemaphore.signal()
            
            self.refreshToken { result in
                switch result {
                case .success(let newToken):
                    tokenManager.accessToken = newToken
                    self.retryFailedRequests()
                case .failure(let error):
                    // 获取所有失败的请求
                    let failedRequests = tokenManager.failedRequests
                    // 重置状态
                    tokenManager.reset()
                    // 通知所有等待的请求失败
                    failedRequests.forEach { $0.1(.failure(error)) }
                }
                completion()
            }
        }
    }
    
    func retryFailedRequests() {
        let tokenManager = TokenManager.shared
        let requests = tokenManager.failedRequests
        
        // 重置状态
        tokenManager.reset()
        
        // 并发重试所有失败的请求
        let group = DispatchGroup()
        
        requests.forEach { target, completion in
            group.enter()
            
            let provider = MoyaProvider<MultiTarget>()
            let multiTarget = MultiTarget(target)
            
            queue.async {
                provider.request(multiTarget) { result in
                    completion(result)
                    group.leave()
                }
            }
        }
        
        // 可以设置一个回调，在所有重试请求完成后执行
        group.notify(queue: .main) {
            print("All retry requests completed")
        }
    }
    
    func refreshToken(completion: @escaping (Result<String, MoyaError>) -> Void) {
        
    }
}
