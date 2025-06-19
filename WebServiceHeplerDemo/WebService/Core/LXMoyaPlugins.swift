//
//  LXPlugins.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/6/19.
//

import Foundation
import Moya

enum LXMoyaPlugins {
    static var defaultMoyaPlugins: [PluginType] {
        var plugins = [PluginType]()
        
        let aesPlugin = LXHandleRequestPlugin()
//        plugins.append(aesPlugin)
#if DEBUG
        plugins.append(HighPrecisionTimingPlugin())
        plugins.append(CurlLoggerPlugin())
        
        let netConfig: NetworkLoggerPlugin
        let haveAes = plugins.contains(where: { $0 is LXHandleRequestPlugin })
        if haveAes == false {
            netConfig = NetworkLoggerPlugin(configuration: .init(logOptions: [.requestHeaders, .requestBody]))
        } else {
            netConfig = NetworkLoggerPlugin(configuration: .init(logOptions: [.requestHeaders, .requestBody]))
        }
        plugins.append(netConfig)
#else
#endif
        return plugins
    }
}
