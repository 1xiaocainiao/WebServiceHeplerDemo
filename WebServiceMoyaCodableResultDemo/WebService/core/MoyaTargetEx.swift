

import Moya

let apiHost: String = "https://www.baidufe.com/test-post.php"
let cityHost: String = "http://t.weather.sojson.com/api/weather/city/101030100"

public struct LXMoyaLoadListStatus {
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

public struct LXMoyaLoadStatus {
    var needLoadDBWhenRefreshing: Bool
    var needCache: Bool
    var clearDataWhenCache: Bool
    
    init(needLoadDBWhenRefreshing: Bool = false,
         needCache: Bool = true,
         clearDataWhenCache: Bool = true) {
        self.needLoadDBWhenRefreshing = needLoadDBWhenRefreshing
        self.needCache = needCache
        self.clearDataWhenCache = clearDataWhenCache
    }
}

/// 暂时没用，在想到时候是否添加缓存支持
public protocol MoyaAddable {
    var cacheKey: String { get }
    
    func loadListStatus() -> LXMoyaLoadListStatus
    
    func loadStatus() -> LXMoyaLoadStatus
}

public extension MoyaAddable {
    var cacheKey: String {
        return "cacheKey"
    }
    
    func loadListStatus() -> LXMoyaLoadListStatus {
        return LXMoyaLoadListStatus()
    }
    
    func loadStatus() -> LXMoyaLoadStatus {
        return LXMoyaLoadStatus()
    }
}

// MARK: - 以下是对targetType扩展

/// 用的时候一般只需要关心 path, method, parameters, encoding, 特殊的自行根据情况处理
/// 举个栗子，如TestPolicyApi 文件，就不继承moya原来的targetType协议了，实现LXMoyaTargetType即可
public protocol LXMoyaTargetType: TargetType {
    /// 一般为接口传参
    var parameters: [String: Any] { get }
    
    ///  参数编码方式
    var encoding: ParameterEncoding { get }
    
    /// 文件上传form, 只有需要上传文件的时候才需要实现此方法
    var uploadFiles: [LXUploadFileInfo]? { get }
}

public extension LXMoyaTargetType {
    var baseURL : URL {
        return URL(string: cityHost)!
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var headers: [String : String]? {
//        if let token = getAccessToken() {
//            return ["Authorization": "Bearer \(token)"]
//        }
        return nil
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
        return URLEncoding.default
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


