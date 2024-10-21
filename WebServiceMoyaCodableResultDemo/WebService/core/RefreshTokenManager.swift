//
//  RefreshTokenManager.swift
//  WebServiceMoyaCodableResultDemo
//
//  Created by mac on 2024/10/21.
//

import Foundation
import Moya

class RefreshTokenManager {
    static let `default` = RefreshTokenManager()
    
    private let tokenKey = "accessToken"
    private let tokenExpirationKey = "tokenExpirationDate"
    
    var isRefreshing: Bool = false
    
    var semaphore = DispatchSemaphore(value: 0)
    
    private init() {
        
    }
    
    func checkAndRefreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
//        if isTokenValid {
//            completion(true)
//            return
//        }
        
        if isRefreshing {
            completion(false)
            return
        }
        
        isRefreshing = true
        
        refreshToken { [weak self] success in
            self?.isRefreshing = false
            
            completion(success)
        }
    }
    
    func refreshToken(completion: @escaping (Bool) -> Void) {
//        let provider = MoyaProvider<AuthAPI>()
//        provider.request(.refreshToken) { result in
//            switch result {
//            case .success(let response):
//                if let refreshResponse = try? response.map(RefreshTokenResponse.self) {
//                    TokenManager.shared.setToken(refreshResponse.token)
//                    completion(true)
//                } else {
//                    completion(false)
//                }
//            case .failure:
//                completion(false)
//            }
//        }
        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
//            self.semaphore.signal()
//            
//            completion(true)
//        }
        
        DispatchQueue.global().async {
            LXWebServiceHelper<CityInfo>().requestJSONModel(TestRequestType.cityTest, progressBlock: nil) { result in
                self.semaphore.signal()
                
                completion(true)
            }
        }
        
        self.semaphore.wait()
    }
    
    var token: String {
        return UserDefaults.standard.string(forKey: tokenKey) ?? ""
    }

    var isTokenValid: Bool {
        guard let expirationDate = UserDefaults.standard.object(forKey: tokenExpirationKey) as? Date else {
            return false
        }
        let now = Date().timeIntervalSince1970
        if (expirationDate.timeIntervalSince1970 - now) < 3600 {
            return false
        }
        return true
    }

    func setToken(_ token: String, expirationInterval: TimeInterval = 3600) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        let expirationDate = Date().addingTimeInterval(expirationInterval)
        UserDefaults.standard.set(expirationDate, forKey: tokenExpirationKey)
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: tokenExpirationKey)
    }
}
