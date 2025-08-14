//
//  UniversalApi.swift
//  PeiWan
//
//  Created by mac on 2024/10/31.
//

import Foundation


enum UniversalApi {
    case globalConfig
    case userNickName
}

extension UniversalApi: LXMoyaTargetType {
    var path: String {
        switch self {
        case .globalConfig:
            return "/public/common/system/global-config-for-system"
        case .userNickName:
            return "/api/user/vn-nickname"
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .globalConfig:
            return [:]
        case .userNickName:
            return [:]
        }
    }
    
    func loadStatus() -> LXMoyaLoadStatus {
        return LXMoyaLoadStatus(isRefresh: true,
                                needLoadDBWhenRefreshing: true,
                                needCache: true,
                                clearDataWhenCache: false)
    }
}
