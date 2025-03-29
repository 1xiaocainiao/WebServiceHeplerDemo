

import Foundation
import Moya

class HighPrecisionTimingPlugin: PluginType {
    private var startTimes: [String: TimeInterval] = [:]
    
    func willSend(_ request: RequestType, target: TargetType) {
        let key = "\(target.method.rawValue)|\(target.path)|\(target.task)"
        startTimes[key] = ProcessInfo.processInfo.systemUptime
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        guard case let .success(response) = result else { return }
        
        // 获取请求对象
        let key = "\(target.method.rawValue)|\(target.path)|\(target.task)"
        guard let startTime = startTimes[key] else { return }
        
        // 计算耗时（毫秒级精度）
        let elapsed = (ProcessInfo.processInfo.systemUptime - startTime) * 1000
        let formattedTime = String(format: "%.3f", elapsed)
        
        // 获取请求信息
        let statusCode = response.statusCode
        let method = target.method.rawValue
        let path = target.path
        
        // 格式化输出
        let logMessage = """
        🌐 网络请求统计
        URL: \(path)
        方法: \(method)
        状态码: \(statusCode)
        耗时: \(formattedTime)ms
        """
        
        printl(message: logMessage)
        
        // 耗时警告(可配置)
        let warningThreshold: Double = 500 // 500ms警告阈值
        if elapsed > warningThreshold {
            printl(message: "⚠️ 警告: 请求超时(超过\(warningThreshold)ms)")
        }
        
        // 清理记录
        startTimes.removeValue(forKey: key)
        
        let cacheKey: String = "HighPrecisionTimingPlugin"
        if let dic: [String: Double] = CacheHelper.default.object(forkey: cacheKey) {
            var newDic = dic
            newDic[key] = elapsed
            CacheHelper.default.set(newDic, forkey: cacheKey)
        } else {
            var dic: [String: Double] = [:]
            dic[key] = elapsed
            CacheHelper.default.set(dic, forkey: cacheKey)
        }
    }
}
