

import Foundation
import Moya



//统一在这里处理请求前的设置和请求后需要处理的数据
class LXHandleRequestPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        switch target.task {
        case .requestParameters(parameters: let params, encoding: _):
            
            guard let encryptData = paramsEncrypt(params: params) else {
                return request
            }
            
            request.httpBody = encryptData
            
            request.setValue(kPublicKey, forHTTPHeaderField: "APPID")
        case .uploadMultipart(_): //上传需要特殊处理，比如同时上传图片和文字时，文字参数是单独加密包含在MultipartFormData的，详情请看TestPolicyApi中含有上传部分
            request.setValue(kPublicKey, forHTTPHeaderField: "APPID")
        default:
            return request
        }
        return request
    }
    
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch result {
        case .success(let successReponse):
            guard let base64DecryptData = Data(base64Encoded: successReponse.data) else {
                return .failure(.parameterEncoding(LXError.serverDataFormatError))
            }
            
            guard let decryptData = AES.default.decrpty(data: base64DecryptData) else {
                return .failure(.parameterEncoding(LXError.serverDataFormatError))
            }
            
            return .success(Response(statusCode: successReponse.statusCode, data: decryptData))
        case .failure(let error):
            return .failure(error)
        }
    }
}
