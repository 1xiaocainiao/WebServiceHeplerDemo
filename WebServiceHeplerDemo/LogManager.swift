//
//  LogManager.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import Foundation
import Foundation

struct LogManager {
    static let logFileName = "NetworkLogs.txt"
    
    // 获取日志文件路径
    static func getLogFileURL() -> URL? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsURL.appendingPathComponent(logFileName)
    }
    
    // 读取日志内容
    static func readLogs() -> String? {
        guard let logFileURL = getLogFileURL() else { return nil }
        
        do {
            let content = try String(contentsOf: logFileURL, encoding: .utf8)
            return content
        } catch {
            printl(message: "读取日志失败: \(error.localizedDescription)")
            return nil
        }
    }
}
