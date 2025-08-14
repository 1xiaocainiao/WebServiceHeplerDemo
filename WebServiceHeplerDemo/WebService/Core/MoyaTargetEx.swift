

import Moya

let apiHost: String = "https://www.baidufe.com/test-post.php"
let cityHost: String = "http://t.weather.sojson.com/api/weather/city/101030100"

public struct LXMoyaLoadStatus {
    var isRefresh: Bool
    var needLoadDBWhenRefreshing: Bool
    var needCache: Bool
    var clearDataWhenCache: Bool
    
    init(isRefresh: Bool = false,
         needLoadDBWhenRefreshing: Bool = false,
         needCache: Bool = true,
         clearDataWhenCache: Bool = true) {
        self.isRefresh = isRefresh
        self.needLoadDBWhenRefreshing = needLoadDBWhenRefreshing
        self.needCache = needCache
        self.clearDataWhenCache = clearDataWhenCache
    }
}

/// 暂时没用，在想到时候是否添加缓存支持
public protocol MoyaLoadAble {
    func loadStatus() -> LXMoyaLoadStatus
}

public extension MoyaLoadAble {
    func loadStatus() -> LXMoyaLoadStatus {
        return LXMoyaLoadStatus()
    }
}

// MARK: - 以下是对targetType扩展

/// 用的时候一般只需要关心 path, method, parameters, encoding, 特殊的自行根据情况处理
/// 举个栗子，如TestPolicyApi 文件，就不继承moya原来的targetType协议了，实现LXMoyaTargetType即可
public protocol LXMoyaTargetType: TargetType, MoyaLoadAble {
    /// 一般为接口传参
    var parameters: [String: Any] { get }
    
    ///  参数编码方式
    var encoding: ParameterEncoding { get }
    
    /// 文件上传form, 只有需要上传文件的时候才需要实现此方法
    var uploadFiles: [LXUploadFileInfo]? { get }
}

public extension LXMoyaTargetType {
    var baseURL : URL {
//        return URL(string: cityHost)!
        return URL(string: KBaseURL)!
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var headers: [String : String]? {
        return LXMoyaHeaderAPI.publicHeaders
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var credentials: CredentialsPlugin? {
//        return CredentialsPlugin { target in
//            return URLCredential(user: "webApp", password: "webApp", persistence: .none)
//        }
        return nil
    }
    
    var parameters: [String: Any] {
        return [:]
    }
    
    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    var task: Task {
        if let files = uploadFiles, files.isNotEmpty {
            var formDatas = files.map { fileInfo in
                return MultipartFormData(provider:
                                            .file(URL(fileURLWithPath: fileInfo.filePath)),
                                         name: fileInfo.fileUploadKey,
                                         fileName: fileInfo.fileName)
            }
            
            if let paramsData = paramsEncrypt(params: parameters.merged(with: publicParams)) {
                let dicData = MultipartFormData(provider: .data(paramsData), name: "data")
                formDatas.append(dicData)
            }
            return .uploadMultipart(formDatas)
        } else {
            return .requestParameters(parameters: parameters.merged(with: publicParams), encoding: encoding)
        }
    }
    
    var uploadFiles: [LXUploadFileInfo]? {
        return nil
    }
    
    /// 底层公共参数
    var publicParams: [String: Any] {
        return [:]
    }
}

enum LXMoyaHeaderAPI {
    static var publicHeaders: [String: String] {
        let info = Bundle.main.infoDictionary
        var resultInfo = [String: String]()
        resultInfo["Platform"] = "ios"
        resultInfo["App-Version"] = info?["CFBundleShortVersionString"] as? String
        
        resultInfo["Device-Id"] = UUID().uuidString
        resultInfo["Build-Number"] = info?["CFBundleVersion"] as? String
        resultInfo["Channel"] = ""
        resultInfo["Language"] = "en"
        resultInfo["Package-Name"] = info?["CFBundleIdentifier"] as? String
        
        resultInfo["OS"] = UIDevice.current.systemName + UIDevice.current.systemVersion
        resultInfo["Device-Model"] = UUID().uuidString
        
//        resultInfo["Content-Type"] = "text/plain"
        return resultInfo
    }
}

// MARK: - Dictionary 扩展
public extension Dictionary {
    mutating func merge<S: Sequence>(conentOf other: S) where S.Iterator.Element == (key: Key, value: Value) {
        for (key, value) in other {
            self[key] = value
        }
    }
    
    func merged<S: Sequence>(with other: S) -> [Key: Value] where S.Iterator.Element == (key: Key, value: Value) {
        var dic = self
        dic.merge(conentOf: other)
        return dic
    }
}

// MARK: - collection not empty
public extension Collection {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}


