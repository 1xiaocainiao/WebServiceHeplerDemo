//
//  LXResult.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import Foundation

enum LXResult<T: Codable> {
    case success(LXResponseContainer<T>)
    case failure(LXError)
}
