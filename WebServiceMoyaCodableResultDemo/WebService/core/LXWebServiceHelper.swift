

import Foundation
import Moya

typealias ResultContainer<T: Codable> = Result<LXResponseContainer<T>, Error>

open class LXWebServiceHelper<T> where T: Codable {
    typealias JSONObjectHandle = (Any) -> Void
    typealias ExceptionHandle = (Error?) -> Void
    typealias ResultContainerHandle = (ResultContainer<T>) -> Void
    
    @discardableResult
    func requestJSONModel<R: LXMoyaTargetType>(_ type: R,
                                               progressBlock: ProgressBlock? = nil,
                                               completionHandle: @escaping ResultContainerHandle) -> Cancellable? {
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
                                                exceptionHandle: @escaping (Error?) -> Void) -> Cancellable? {
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

