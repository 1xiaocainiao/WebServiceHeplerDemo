import Foundation
import Moya

enum TokenRefreshError: Error {
    case refreshInProgress
    case refreshFailed
    case maxRetryReached
}

class TokenRefreshPlugin: PluginType {
    private let queue = DispatchQueue(label: "com.yourapp.tokenrefresh")
    private var isRefreshing = false
    private var requestsToRetry: [(TargetType, (Result<Response, MoyaError>) -> Void)] = []
    private let maxRetryCount = 3
    private var retryCount = 0

    private let tokenExpirationKey = "tokenExpirationDate"

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        if let token = TokenManager.shared.token, TokenManager.shared.isTokenValid {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch result {
        case .success(let response):
            if response.statusCode == 401 {
                return handleUnauthorized(response: response, target: target)
            }
        case .failure:
            break
        }
        return result
    }

    private func handleUnauthorized(response: Response, target: TargetType) -> Result<Response, MoyaError> {
        var result: Result<Response, MoyaError> = .failure(MoyaError.underlying(TokenRefreshError.refreshFailed, response))
        
        queue.sync { [weak self] in
            guard let self = self else {
                result = .failure(MoyaError.underlying(TokenRefreshError.refreshFailed, response))
                return
            }

            if self.retryCount >= self.maxRetryCount {
                self.retryCount = 0
                result = .failure(MoyaError.underlying(TokenRefreshError.maxRetryReached, response))
                return
            }

            if self.isRefreshing {
                let completion: (Result<Response, MoyaError>) -> Void = { result in
                    
                }
                self.requestsToRetry.append((target, completion))
                result = .failure(MoyaError.underlying(TokenRefreshError.refreshInProgress, response))
                return
            }

            self.retryCount += 1
            self.isRefreshing = true

            let semaphore = DispatchSemaphore(value: 0)

            self.refreshToken { success in
                if success {
                    self.requestsToRetry.forEach { (target, completion) in
                        MoyaProvider().request(target, completion: completion)
                    }
                    self.requestsToRetry.removeAll()
                    result = .success(response)  // 假设刷新成功后，我们返回原始响应
                } else {
                    result = .failure(MoyaError.underlying(TokenRefreshError.refreshFailed, response))
                }
                self.isRefreshing = false
                self.retryCount = 0
                semaphore.signal()
            }

            semaphore.wait()
        }
        
        return result
    }

    private func refreshToken(completion: @escaping (Bool) -> Void) {
        let provider = MoyaProvider<AuthAPI>()
        provider.request(.refreshToken) { result in
            switch result {
            case .success(let response):
                if let refreshResponse = try? response.map(RefreshTokenResponse.self) {
                    TokenManager.shared.setToken(refreshResponse.token)
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }

    func clearToken() {
        TokenManager.shared.clearToken()
    }

    func forceRefreshToken(completion: @escaping (Bool) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(false)
                return
            }
            if self.isRefreshing {
                completion(false)
                return
            }
            self.isRefreshing = true
            self.refreshToken { success in
                self.isRefreshing = false
                completion(success)
            }
        }
    }

    func checkAndRefreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(false)
                return
            }
            if TokenManager.shared.isTokenValid {
                completion(true)
                return
            }
            if self.isRefreshing {
                completion(false)
                return
            }
            self.isRefreshing = true
            self.refreshToken { success in
                self.isRefreshing = false
                completion(success)
            }
        }
    }
}

class TokenManager {
    static let shared = TokenManager()
    private let tokenKey = "accessToken"
    private let tokenExpirationKey = "tokenExpirationDate"

    private init() {}

    var token: String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }

    var isTokenValid: Bool {
        guard let expirationDate = UserDefaults.standard.object(forKey: tokenExpirationKey) as? Date else {
            return false
        }
        return Date() < expirationDate
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
