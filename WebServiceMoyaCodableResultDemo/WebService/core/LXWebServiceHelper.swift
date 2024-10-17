

import Foundation
import Moya
import Combine

typealias ResultContainer<T: Codable> = Result<LXResponseContainer<T>, Error>

open class LXWebServiceHelper<T> where T: Codable {
    typealias JSONObjectHandle = (Any) -> Void
    typealias ExceptionHandle = (Error?) -> Void
    typealias ResultContainerHandle = (ResultContainer<T>) -> Void
    
    @discardableResult
    func requestJSONModel<R: LXMoyaTargetType>(_ type: R,
                                               progressBlock: ProgressBlock? = nil,
                                               completionHandle: @escaping ResultContainerHandle) -> Moya.Cancellable? {
        return requestJSONObject(type, progressBlock: progressBlock) { result in
            let result: ResultContainer<T> = parseResponseToResult(responseObject: result, error: nil)
            completionHandle(result)
        } exceptionHandle: { error in
            let result: ResultContainer<T> = parseResponseToResult(responseObject: nil, error: error)
            completionHandle(result)
        }
    }
    
    // 可自定义加解密插件等
    private func createProvider<R: LXMoyaTargetType>(type: R) -> MoyaProvider<R> {
        let activityPlugin = NetworkActivityPlugin { state, targetType in
            self.networkActiviyIndicatorVisible(visibile: state == .began)
        }
        
        //        let aesPlugin = LXHandleRequestPlugin()
        
        let crePlugin = type.credentials
        
        var plugins = [PluginType]()
        plugins.append(activityPlugin)
        
        if crePlugin != nil {
            plugins.append(crePlugin!)
        }
        
#if DEBUG
        plugins.append(NetworkLoggerPlugin(configuration: .init(logOptions: [.requestHeaders, .requestBody, .successResponseBody])))
#else
#endif
        
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
                                                progressBlock: ProgressBlock?,
                                                completionHandle: @escaping JSONObjectHandle,
                                                        exceptionHandle: @escaping (Error?) -> Void) -> Moya.Cancellable? {
        let provider = createProvider(type: type)
        let cancelable = provider.request(type, callbackQueue: nil, progress: progressBlock) { result in
            switch result {
            case .success(let successResponse):
                do {
//#if DEBUG
//                    let json = String(data: successResponse.data, encoding: .utf8) ?? ""
//                    print(json)
//#else
//#endif
                    let jsonObject = try successResponse.mapJSON()
                    
                    completionHandle(jsonObject)
                } catch  {
                    exceptionHandle(LXError.serverDataFormatError)
                }
                break
            case .failure(let error):
                if error.errorCode == NSURLErrorTimedOut {
                    exceptionHandle(LXError.networkConnectTimeOut)
                } else {
                    exceptionHandle(LXError.networkConnectFailed)
                }
                break
            }
        }
        return cancelable
    }
}

// MARK: - combine支持, 注意下面两种写法的不同
extension LXWebServiceHelper {
    
//    func requestJsonModelPublisher<R: LXMoyaTargetType>(_ type: R,
//                                                        progressBlock: ProgressBlock?) -> AnyPublisher<LXResponseContainer<T>, Error> {
//        return Future<LXResponseContainer<T>, Error> { promise in
//            self.requestJSONObject(type, progressBlock: progressBlock) { response in
//                let result: ResultContainer<T> = parseResponseToResult(responseObject: response, error: nil)
//                switch result {
//                case .success(let container):
//                    promise(.success(container))
//                case .failure(let error):
//                    promise(.failure(error))
//                }
//            } exceptionHandle: { error in
//                let result: ResultContainer<T> = parseResponseToResult(responseObject: nil, error: error)
//                switch result {
//                case .success(let container):
//                    promise(.success(container))
//                case .failure(let error):
//                    promise(.failure(error))
//                }
//            }
//        }.eraseToAnyPublisher()
//    }
    
    /// progress暂时不可用
    func requestJsonModelPublisher<R: LXMoyaTargetType>(_ type: R,
                                                        progressBlock: ProgressBlock?) -> AnyPublisher<ResultContainer<T>, Never> {
        return Future<ResultContainer<T>, Never> { promise in
            self.requestJSONModel(type, progressBlock: progressBlock) { result in
                promise(.success(result))
            }
        }.eraseToAnyPublisher()
    }
}


