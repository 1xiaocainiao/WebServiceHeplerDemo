

///
///  curl日志打印插件, 可直接导入postman等工具
///

import Foundation
import Moya

struct CurlLoggerPlugin: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        guard let urlRequest = request.request else { return }
        
        var curlCommand = "curl \\\n"
        
        if let httpMethod = urlRequest.httpMethod {
            curlCommand += "-X \(httpMethod) \\\n"
        }
        
        if let url = urlRequest.url?.absoluteString {
            curlCommand += "\"\(url)\" \\\n"
        }
        
        // HTTP 头
        urlRequest.allHTTPHeaderFields?.forEach { key, value in
            let escapedValue = value.replacingOccurrences(of: "\"", with: "\\\"")
            curlCommand += "-H \"\(key): \(escapedValue)\" \\\n"
        }
        
        // HTTP 主体
        if let httpBody = urlRequest.httpBody {
            if let bodyString = String(data: httpBody, encoding: .utf8) {
                let escapedBody = bodyString.replacingOccurrences(of: "\"", with: "\\\"")
                curlCommand += "-d \"\(escapedBody)\" \\\n"
            }
        }
        
        // 移除最后的反斜杠和换行
        curlCommand = String(curlCommand.dropLast(3))
        
        printl(message: "✅ cURL Command:")
        printl(message: curlCommand)
        printl(message: "----------------------------")
    }
}
