//
//  LXWebServiceHelper.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import Foundation
import Moya

open class LXWebServiceHelper<T> where T: Codable {
    typealias JSONObjectHandle = (Any) -> Void
    typealias ExceptionHandle = (LXError) -> Void
    typealias ResultContainerHandle = (LXResult<T>) -> Void
    
    @discardableResult
    func requestJSONModel<R: LXMoyaTargetType>(_ type: R,
                                               context: RequestContext = .init(),
                                               progressBlock: ProgressBlock? = nil,
                                               completionHandle: @escaping ResultContainerHandle) -> Moya.Cancellable? {
        return requestJSONObject(type, context: context, progressBlock: progressBlock) { [weak self] result in
            let result: LXResult<T> = parseResponseToResult(responseObject: result,
                                                                   error: nil)
            switch result {
            case .success( _):
                break
            case .failure(let error):
                self?.handleError(error, context: context)
            }
            completionHandle(result)
        } exceptionHandle: { [weak self] error in
            let result: LXResult<T> = parseResponseToResult(responseObject: nil,
                                                                   error: error)
            self?.handleError(error, context: context)
            completionHandle(result)
        }
    }
    
    @discardableResult
    func requestJSONRawObject<R: LXMoyaTargetType>(_ type: R,
                                                   context: RequestContext = .init(),
                                                progressBlock: ProgressBlock? = nil,
                                                completionHandle: @escaping JSONObjectHandle,
                                                exceptionHandle: @escaping (LXError) -> Void) -> Moya.Cancellable?  {
        return requestJSONObject(type,
                                 context: context,
                                 progressBlock: progressBlock,
                                 completionHandle: completionHandle,
                                 exceptionHandle: exceptionHandle)
    }
    
    // 可自定义加解密插件等
    private func createProvider<R: LXMoyaTargetType>(type: R) -> MoyaProvider<R> {
        let activityPlugin = NetworkActivityPlugin { state, targetType in
            self.networkActiviyIndicatorVisible(visibile: state == .began)
        }
        
        let crePlugin = type.credentials
        
        var plugins = [PluginType]()
        plugins.append(activityPlugin)
        
        if crePlugin != nil {
            plugins.append(crePlugin!)
        }
        
//        let aesPlugin = LXHandleRequestPlugin()
//        plugins.append(aesPlugin)
        
#if DEBUG
        plugins.append(HighPrecisionTimingPlugin())
        plugins.append(NetworkLoggerPlugin(configuration: .init(logOptions: [.requestHeaders, .requestBody,/* .successResponseBody*/])))
#else
#endif
        
        // 超时设置
//        let requestTimeoutClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<R>.RequestResultClosure) in
//            do {
//                var request = try endpoint.urlRequest()
//                request.timeoutInterval = 30
//                done(.success(request))
//            } catch {
//                done(.failure(MoyaError.underlying(error, nil)))
//            }
//        }
        
        // 需要无感刷新token使用下面的代码
//        let requestClorure = MoyaProvider<R>.endpointResolver()
//        let provider = MoyaProvider<R>(requestClosure: requestClorure, plugins: plugins)
        
        // 不需要无感刷新token
        let provider = MoyaProvider<R>(plugins: plugins)
        
        return provider
    }
    
    private func networkActiviyIndicatorVisible(visibile: Bool) {
        if #available(iOS 13, *) {
            
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = visibile
        }
    }
    
    @discardableResult
    private func requestJSONObject<R: LXMoyaTargetType>(_ type: R,
                                                        context: RequestContext = .init(),
                                                progressBlock: ProgressBlock?,
                                                completionHandle: @escaping JSONObjectHandle,
                                                        exceptionHandle: @escaping (LXError) -> Void) -> Moya.Cancellable? {
        if !NetworkMonitor.default.isConnected {
            DispatchQueue.mainAsync {
                exceptionHandle(LXError.networkConnectFailed)
            }
            return nil
        }
        let provider = createProvider(type: type)
        let cancelable = provider.request(type, callbackQueue: nil, progress: progressBlock) { result in
            switch result {
            case .success(let successResponse):
                if successResponse.statusCode == 200 {
                    do {
                        let jsonObject = try successResponse.mapJSON()
                        
                        #if DEBUG
                        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                           let jsonString = String(data: jsonData, encoding: .utf8) {
                            printl(message: "response jsonString: \n \(jsonString)")
                        }
                        #else
                        #endif
                        
                        completionHandle(jsonObject)
                    } catch  {
                        exceptionHandle(LXError.serverDataFormatError)
                    }
                } else {
                    exceptionHandle(LXError.serverResponseError(message: successResponse.description,
                                                                code: successResponse.statusCode))
                }
                break
            case .failure(let error):
                exceptionHandle(error.asLXError())
                break
            }
        }
        return cancelable
    }
}

// MARK: - 错误处理
extension LXWebServiceHelper {
    fileprivate func handleError(_ error: LXError, context: RequestContext) {
        DefaultErrorHandler.handle(error: error, context: context)
    }
}

// MARK: - async await支持
extension LXWebServiceHelper {
    func requestJSONRawObjectAsync<R: LXMoyaTargetType>(
        _ type: R,
        context: RequestContext = .init()
    ) async throws -> Any {
        try await withCheckedThrowingContinuation { continuation in
            requestJSONRawObject(
                type,
                context: context,
                progressBlock: nil
            ) { json in
                continuation.resume(returning: json)
            } exceptionHandle: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    // 返回LXResponseContainer,需要单独处理error
    func requestJSONModelThrowingAsync<R: LXMoyaTargetType>(
        _ type: R,
        context: RequestContext = .init()
    ) async throws -> LXResponseContainer<T> {
        try await withCheckedThrowingContinuation { continuation in
            requestJSONModel(
                type,
                context: context,
                progressBlock: nil
            ) { result in
                switch result {
                case .success(let container):
                    continuation.resume(returning: container)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // 返回LXResult
    func requestJSONModelAsync<R: LXMoyaTargetType>(
        _ type: R,
        context: RequestContext = .init()
    ) async -> LXResult<T> {
        return await withCheckedContinuation { continuation in
            requestJSONModel(
                type,
                context: context,
                progressBlock: nil
            ) { result in
                continuation.resume(returning: result)
            }
        }
    }
}

// MARK: - 支持 cancellable, 未测试，未使用
extension LXWebServiceHelper {
    func requestJSONRawObjectCancellableAsync<R: LXMoyaTargetType>(
        _ type: R,
        context: RequestContext = .init()
    ) async throws -> Any {
        let ctx = ContextCancellable()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                // 启动请求
                ctx.cancellable = requestJSONRawObject(
                    type,
                    context: context,
                    progressBlock: nil
                ) { json in
                    continuation.resume(returning: json)
                } exceptionHandle: { error in
                    continuation.resume(throwing: error)
                }

                // 检查是否在启动前已被取消
                if _Concurrency.Task.isCancelled { // ✅ 正确用法：通过当前 Task 的上下文检查
                    ctx.cancellable?.cancel()
                }
            }
        } onCancel: {
            ctx.cancellable?.cancel()
        }
    }
}

// 使用类包装 Cancellable 和状态
final class ContextCancellable {
    var cancellable: Moya.Cancellable?
}
