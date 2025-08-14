//
//  GlobalModel.swift
//  PeiWan
//
//  Created by mac on 2024/11/6.
//

import Foundation

class GlobalModel: DatabaseTable {
    var im_appid: String?
    // 1
    var helper_user_id: Int?
    
    static var tableName: String {
        return "config"
    }
    
    static func primaryKey() -> String {
        return "im_appid"
    }
}
