//
//  LXResponseContainer.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import Foundation

/// 后端返回的code
public struct ResponseCode {
    static let successResponseStatusCode: Int = 200
}

enum ResutType {
    case origin
    case model
    case array
}

enum ValueType<T: Codable> {
    case object(T)
    case array([T])
    
    var values: [T]? {
        switch self {
        case .object(_):
            return nil
        case .array(let array):
            return array
        }
    }
    
    var value: T? {
        switch self {
        case .object(let t):
            return t
        case .array(_):
            return nil
        }
    }
}

/// 需要根据实际情况修改，这个只是demo请求使用
struct LXResponseContainer<T: Codable> {
    let rawObject: Any?
    let code: Int?
    let message: String?
    
    let rawData: Any?
    let valueType: ValueType<T>?
    
    let type: ResutType
    
    init(rawObject: Any?,
         code: Int?,
         message: String?,
         type: ResutType,
         rawData: Any? = nil,
         valueType: ValueType<T>? = nil) {
        self.rawObject = rawObject
        self.code = code
        self.message = message
        self.type = type
        
        self.rawData = rawData
        self.valueType = valueType
    }
}

func parseResponseToResult<T: Codable>(responseObject: Any?,
                                       type: ResutType) -> LXResult<T> {
    /// 检查数据完整性，根据自己项目实际情况进行修改
    guard let jsonObject = responseObject as? [String: Any],
          let message = jsonObject[ServerKey.message.rawValue] as? String else {
        return .failure(LXError.serverDataFormatError)
    }
    
    guard let statusCode = jsonObject[ServerKey.code.rawValue] as? Int else {
        return .failure(LXError.missStatuCode)
    }
    
    if statusCode == ResponseCode.successResponseStatusCode {
        guard let jsonValue = jsonObject[ServerKey.value.rawValue] else {
            return .failure(LXError.missDataContent)
        }
        
        // 这两个一般用不到，只有会端data乱来才需要检查
//        guard !(jsonValue is NSNull) else {
//            return .success(LXResponseContainer(rawObject: nil,
//                                                code: statusCode,
//                                                message: message,
//                                                type: type,
//                                                valueType: nil))
//        }
//        if let tempArray = jsonValue as? Array<Any>, tempArray.isEmpty {
//            return .success(LXResponseContainer(rawObject: nil,
//                                                code: statusCode,
//                                                message: message,
//                                                type: type,
//                                                valueType: nil))
//        }
        
        switch type {
        case .origin:
            return .success(LXResponseContainer(rawObject: jsonObject,
                                                code: statusCode,
                                                message: message,
                                                type: type,
                                                rawData: jsonValue))
        case .model:
            if let jsonDic = jsonValue as? [String: Any] {
                let data = jsonDic.toData()
                do {
                    let model: T = try decodeToModel(responseData: data)
                    return .success(LXResponseContainer(rawObject: jsonObject,
                                                        code: statusCode,
                                                        message: message,
                                                        type: type,
                                                        rawData: jsonValue,
                                                        valueType: .object(model)))
                } catch let error {
                    if let err = error as? LXError {
                        return .failure(err)
                    } else {
                        return .failure(LXError.exception(message: error.localizedDescription))
                    }
                }
            } else {
                return .failure(LXError.dataContentTransformToModelFailed)
            }
        case .array:
            if let jsonArray = jsonValue as? Array<[String: Any]> {
                var resultValues: [T] = []
                for jsonDic in jsonArray {
                    let data = jsonDic.toData()
                    do {
                        let model: T = try decodeToModel(responseData: data)
                        resultValues.append(model)
                    } catch let error {
                        if let err = error as? LXError {
                            return .failure(err)
                        } else {
                            return .failure(LXError.exception(message: error.localizedDescription))
                        }
                    }
                }
                return .success(LXResponseContainer(rawObject: jsonObject,
                                                    code: statusCode,
                                                    message: message,
                                                    type: type,
                                                    rawData: jsonValue,
                                                    valueType: .array(resultValues)))
            } else {
                return .failure(LXError.dataContentTransformToModelFailed)
            }
        }
    } else {
        return .failure(LXError.serverResponseError(message: message, code: statusCode))
    }
}

func decodeToModel<T: Codable>(responseData: Data?) throws -> T {
    guard let data = responseData else {
        throw LXError.missDataContent
    }
    
    do {
        let model = try JSONDecoder().decode(T.self, from: data)
        return model
    } catch DecodingError.keyNotFound(let key, let context) {
        printl(message: "keyNotFound: \(key) is not found in JSON: \(context.debugDescription)")
        throw LXError.dataContentTransformToModelFailed
    } catch DecodingError.valueNotFound(let type, let context) {
        printl(message: "valueNotFound: \(type) is not found in JSON: \(context.debugDescription)")
        throw LXError.dataContentTransformToModelFailed
    } catch DecodingError.typeMismatch(let type, let context) {
        printl(message: "typeMismatch: \(type) is mismatch in JSON: \(context.debugDescription) \(context.codingPath)")
        throw LXError.dataContentTransformToModelFailed
    } catch DecodingError.dataCorrupted(let context) {
        printl(message: "dataCorrupted: \(context.debugDescription)")
        throw LXError.dataContentTransformToModelFailed
    } catch let error {
        printl(message: "error: \(error.localizedDescription)")
        throw LXError.exception(message: error.localizedDescription)
    }
}
