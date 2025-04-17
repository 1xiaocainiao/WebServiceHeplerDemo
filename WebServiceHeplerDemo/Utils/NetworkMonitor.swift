

import Foundation

class NetworkMonitor {
    static let `default` = NetworkMonitor()
    
    private init() {
        startMonitoring()
    }

    private var reachability: Reachability?
    
    var isConnected: Bool {
        return reachability?.connection != .unavailable
    }

    func startMonitoring() {
        do {
            reachability = try Reachability()
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(reachabilityChanged), name:.reachabilityChanged,
                                                   object: reachability)
            try reachability?.startNotifier()
        } catch {
            printl(message: "无法启动网络监听：\(error)")
        }
    }

    @objc func reachabilityChanged(_ notification: Notification) {
        guard let reachability = notification.object as? Reachability else { return }
        switch reachability.connection {
        case .unavailable:
            printl(message: "网络不可用")
        case .cellular,
                .wifi:
            printl(message: "有网络")
            
            checkFirstAllowNetwork()
        }
    }
    
    func stopMoinitoring() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: .reachabilityChanged,
                                                  object: reachability)
    }
    
    // 检查第一次安装有网络请求通用配置
    func checkFirstAllowNetwork() {
//        if let isFirstLaunch: Bool = CacheHelper.default.object(forkey: CachePropertyKey.isFirstClickAllowNetworkKey) {
//            printl(message: "不是第一次安装")
//        } else {
//            printl(message: "是第一次安装")
//            printl(message: "请求通用配置接口")
//            CacheHelper.default.set(true, forkey: CachePropertyKey.isFirstClickAllowNetworkKey)
//            
//            DataCacheHelper.default.loadWhenLaunch()
//        }
    }
}

extension NetworkMonitor {
    static func showToastWhenNoNetwork(show: Bool = true) -> Bool {
        if !isConnected, show {
//            SVProgressHUD.showText(status: LXLocalizedString("net_connect_error"))
        }
        return !isConnected
    }
    
    static var isConnected: Bool {
        return NetworkMonitor.default.isConnected
    }
}
