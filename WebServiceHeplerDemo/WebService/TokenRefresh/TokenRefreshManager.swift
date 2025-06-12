//
//  TokenRefreshManager.swift
//  WebServiceMoyaCodableResultDemo
//
//  Created by mac on 2024/11/13.
//

// 目前项目使用过

import Foundation

// MARK: - lock 加锁
//class TokenRefreshManager {
//    static let shared = TokenRefreshManager()
//    private init() {}
//
//    private let queue = DispatchQueue.global(qos: .background)
//    private var isRefreshing = false
//
//    // Replace the array with a Queue
//    private var pendingRequests = LockQueue<() -> Void>()
//
//    func executeWithRefreshToken(_ request: @escaping () -> Void) {
//        queue.async { [weak self] in
//            guard let self = self else { return }
//
//            if self.isTokenValid() {
//                DispatchQueue.main.async {
//                    request()
//                }
//            } else if self.isRefreshing {
//                self.pendingRequests.enqueue(request)
//            } else {
//                self.refreshToken {
//                    DispatchQueue.main.async {
//                        request()
//                        self.executePendingRequests()
//                    }
//                }
//            }
//        }
//    }
//
//    private func isTokenValid() -> Bool {
//        return false
//
////        if let inValid = LoginResultModel.currentInfo()?.tokenInValid {
////            return !inValid
////        }
////        return true
//    }
//
//    private func refreshToken(completion: @escaping () -> Void) {
//        isRefreshing = true
//
//        MoyaProvider<UniversalApi>().request(UniversalApi.tokenRefresh) { [weak self] result in
//            guard let self = self else { return }
//
//            defer {
//                self.isRefreshing = false
//                completion()
//            }
//
//            switch result {
//            case .success(let response):
//                do {
//                    let jsonObject = try response.mapJSON()
//                    printl(message: "刷新 token 接口 \(jsonObject)")
//
//                    let container: ResultContainer<LoginResultModel> = parseResponseToResult(responseObject: jsonObject, error: nil)
//                    switch container {
//                    case .success(let model):
//                        LoginResultModel.updateToken(model.value?.token, exp: model.value?.exp)
//                    case .failure(_):
//                        printl(message: "刷新token 模型解析失败")
//                    }
//                } catch {
//                    printl(message: "刷新token JSON解析失败: \(error)")
//                }
//
//            case .failure(_):
//                // 刷新失败直接退出
//                DispatchQueue.main.async {
//                    AppDelegate.app?.enterLogin()
//                }
//            }
//        }
//    }
//
//    private func executePendingRequests() {
//        DispatchQueue.main.async {
//            while let request = self.pendingRequests.dequeue() {
//                request()
//            }
//        }
//    }
//}
//
//// Add this Queue implementation at the end of the file
//struct LockQueue<T> {
//    private var elements: [T] = []
//    private let lock = NSLock()
//
//    mutating func enqueue(_ element: T) {
//        lock.lock()
//        defer { lock.unlock() }
//        elements.append(element)
//    }
//
//    mutating func dequeue() -> T? {
//        lock.lock()
//        defer { lock.unlock() }
//        return elements.isEmpty ? nil : elements.removeFirst()
//    }
//
//    var isEmpty: Bool {
//        lock.lock()
//        defer { lock.unlock() }
//        return elements.isEmpty
//    }
//}

// MARK: - 数组实现
//class TokenRefreshManager {
//    static let shared = TokenRefreshManager()
//    private init() {}
//
//    private let queue = DispatchQueue.global(qos: .background)
//    private var isRefreshing = false
//    private var pendingRequests: [() -> Void] = []
//
//    func executeWithRefreshToken(_ request: @escaping () -> Void) {
//        queue.async { [weak self] in
//            guard let self = self else { return }
//
//            if self.isTokenValid() {
//                request()
//            } else if self.isRefreshing {
//                self.pendingRequests.append(request)
//            } else {
//                self.refreshToken {
//                    request()
//                    self.executePendingRequests()
//                }
//            }
//        }
//    }
//
//    private func isTokenValid() -> Bool {
//        if let inValid = LoginResultModel.currentInfo()?.tokenInValid {
//            return !inValid
//        }
//        return true
//    }
//
//    private func refreshToken(completion: @escaping () -> Void) {
//        isRefreshing = true
//
//        DispatchQueue.main.async {
//            MoyaProvider<UniversalApi>().request(UniversalApi.tokenRefresh) { result in
//
//                defer {
//                    self.isRefreshing = false
//
//                    completion()
//                }
//                switch result {
//                case .success(let response):
//                    guard let jsonObject = try? response.mapJSON() else {
//                        return
//                    }
//
//                    printl(message: "刷新 token 接口 \(jsonObject)")
//
//                    let container: ResultContainer<LoginResultModel> = parseResponseToResult(responseObject: jsonObject, error: nil)
//                    switch container {
//                    case .success(let model):
//                        LoginResultModel.updateToken(model.value?.token, exp: model.value?.exp)
//                    case .failure(_):
//                        printl(message: "刷新token 模型解析失败")
//                    }
//
//
//                case .failure(_):
//                    /// 刷新失败直接退出
//                    AppDelegate.app?.enterLogin()
//                }
//            }
//        }
//    }
//
//    private func executePendingRequests() {
//        DispatchQueue.main.async {
//            self.pendingRequests.forEach { $0() }
//            self.pendingRequests.removeAll()
//        }
//    }
//}

// MARK: - 目前项目使用
class TokenRefreshManager {
    static let shared = TokenRefreshManager()
    private init() {}
    
    private let queue = DispatchQueue.global(qos: .background)
    private var isRefreshing = false
    
    // Replace LockQueue with DispatchQueue-based implementation
    private let pendingRequestsQueue = DispatchQueue(label: "com.yourapp.pendingRequests", attributes: .concurrent)
    private var pendingRequests: [() -> Void] = []
    
    func executeWithRefreshToken(_ request: @escaping () -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if self.isTokenValid() {
                DispatchQueue.main.async {
                    request()
                }
            } else if self.isRefreshing {
                self.pendingRequestsQueue.async(flags: .barrier) {
                    self.pendingRequests.append(request)
                }
            } else {
                self.refreshToken {
                    DispatchQueue.main.async {
                        request()
                        self.executePendingRequests()
                    }
                }
            }
        }
    }
    
    private func isTokenValid() -> Bool {
        // 第一次安装时默认ture,别改
        return true
        
//        if let inValid = LoginResultModel.currentInfo()?.tokenInValid {
//            return !inValid
//        }
//        return true
    }
    
    private func refreshToken(completion: @escaping () -> Void) {
        isRefreshing = true
        
//        MoyaProvider<UniversalApi>().request(UniversalApi.tokenRefresh) { [weak self] result in
//            guard let self = self else { return }
//            
//            defer {
//                self.isRefreshing = false
//                completion()
//            }
//            
//            switch result {
//            case .success(let response):
//                do {
//                    let jsonObject = try response.mapJSON()
//                    printl(message: "刷新 token 接口 \(jsonObject)")
//                    
//                    let container: ResultContainer<LoginResultModel> = parseResponseToResult(responseObject: jsonObject, error: nil)
//                    switch container {
//                    case .success(let model):
//                        LoginResultModel.updateToken(model.value?.token, exp: model.value?.exp)
//                    case .failure(_):
//                        printl(message: "刷新token 模型解析失败")
//                    }
//                } catch {
//                    printl(message: "刷新token JSON解析失败: \(error)")
//                }
//                
//            case .failure(_):
//                // 刷新失败直接退出
//                DispatchQueue.main.async {
//                    AppDelegate.app?.enterLogin()
//                }
//            }
//        }
    }
    
    private func executePendingRequests() {
        pendingRequestsQueue.async(flags: .barrier) {
            let requests = self.pendingRequests
            self.pendingRequests.removeAll()
            
            DispatchQueue.main.async {
                requests.forEach { $0() }
            }
        }
    }
}
