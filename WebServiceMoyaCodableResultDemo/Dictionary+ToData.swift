//
//  Dictionary+ToData.swift
//  live
//
//  Created by  on 2022/9/22.
//

import Foundation

extension Dictionary {
    func toData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self)
    }
    
    func toJsonString() -> String? {
        guard let data = self.toData() else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
