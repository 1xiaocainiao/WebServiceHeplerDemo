//
//  HighPrecisionTimingPlugin.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import Foundation
import Moya

class HighPrecisionTimingPlugin: PluginType {
    private var startTimes: [String: TimeInterval] = [:]
    private let logFileName = LogManager.logFileName
    private let fileQueue = DispatchQueue(label: "com.yourApp.networkLogger") // 串行队列确保线程安全

    // MARK: - 写入日志到文件
    private func writeLogToFile(_ message: String) {
        fileQueue.async {
            let fileManager = FileManager.default
            guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            let logFileURL = documentsURL.appendingPathComponent(self.logFileName)
            
            // 添加换行符
            let logMessage = message + "\n"
            
            // 追加内容到文件
            if let handle = try? FileHandle(forWritingTo: logFileURL) {
                handle.seekToEndOfFile()
                handle.write(logMessage.data(using: .utf8)!)
                try? handle.close()
            } else {
                try? logMessage.data(using: .utf8)?.write(to: logFileURL)
            }
            
            // 打印文件路径（调试用）
            printl(message: "日志文件路径: \(logFileURL.path)")
        }
    }

    // MARK: - Moya 插件方法
    func willSend(_ request: RequestType, target: TargetType) {
        let key = "\(target.method.rawValue)|\(target.path)|\(target.task)"
        startTimes[key] = ProcessInfo.processInfo.systemUptime
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        guard case let .success(response) = result else { return }
        
        let key = "\(target.method.rawValue)|\(target.path)|\(target.task)"
        guard let startTime = startTimes[key] else { return }
        
        let elapsed = (ProcessInfo.processInfo.systemUptime - startTime) * 1000
        let formattedTime = String(format: "%.3f", elapsed)
        let statusCode = response.statusCode
        let method = target.method.rawValue
        let path = target.path
        
        let logMessage = """
        🌐 网络请求统计
        URL: \(path)
        方法: \(method)
        状态码: \(statusCode)
        耗时: \(formattedTime)ms
        """
        
        // 写入文件
        writeLogToFile(logMessage)
        
        // 耗时警告（示例阈值 500ms）
        if elapsed > 500 {
            let warningMessage = "⚠️ 警告: 请求超时(超过 500ms)"
            writeLogToFile(warningMessage)
        }
        
        startTimes.removeValue(forKey: key)
    }
}
