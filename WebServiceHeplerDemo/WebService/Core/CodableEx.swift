//
//  CodableEx.swift
//  WebserviceMoyaCodableDemo
//
//  Created by  on 2022/1/12.
//

import Foundation

public extension Encodable {
    func asJSON() -> String? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func asJSONObject() -> Any? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
}
