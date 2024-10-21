//
//  MoyaProviderEX.swift
//  WebServiceMoyaCodableResultDemo
//
//  Created by mac on 2024/10/21.
//

import Foundation
import Moya

extension MoyaProvider {
    convenience init(handleRefreshToken: Bool) {
        if handleRefreshToken {
            self.init(requestClosure: MoyaProvider.endpointResolver())
        } else {
            self.init()
        }
    }
    
    // 刷新token的设置
    static func endpointResolver() -> MoyaProvider<Target>.RequestClosure {
        return { (endpoint, closure) in
            //Getting the original request
            let request = try! endpoint.urlRequest()
            
            //assume you have saved the existing token somewhere
            if (false) {
                // Token is valid, so just resume the original request
                closure(.success(request))
                return
            }
            
            //Do a request to refresh the authtoken based on refreshToken
//            authenticationProvider.request(.refreshToken(params)) { result in
//                switch result {
//                case .success(let response):
//                    let token = response.mapJSON()["token"]
//                    let newRefreshToken = response.mapJSON()["refreshToken"]
//                    //overwrite your old token with the new token
//                    //overwrite your old refreshToken with the new refresh token
//
//                    closure(.success(request)) // This line will "resume" the actual request, and then you can use AccessTokenPlugin to set the Authentication header
//                case .failure(let error):
//                    closure(.failure(error)) //something went terrible wrong! Request will not be performed
//                }
//            }
            
            /// 暂时不要用自己封装的，有点问题
            MoyaProvider<TestRequestType>().request(TestRequestType.baidu) { result in
                switch result {
                case .success(let response):
                    let jsonObject = try? response.mapJSON()
                    printl(message: jsonObject ?? "")
                    
                    closure(.success(request))
                case .failure(let error):
                    closure(.failure(error))
                }
            }
            
            /// 这里加自己的刷新token的接口
//            LXWebServiceHelper<UserInfo>().requestJSONModel(TestRequestType.baidu, progressBlock: nil) { result in
//                switch result {
//                case .success(let container):
//                    printl(message: container.value?.city)
//                    closure(.success(request))
//                case .failure(let error):
//                    closure(.failure(error as! MoyaError))
//                }
//            }
            
        }
    }
}
