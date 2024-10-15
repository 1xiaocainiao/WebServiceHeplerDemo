

import UIKit


class TestModel: Codable {
    var user_info: UserInfo?
    var site: SiteModel?
}

class UserInfo: Codable {
    var trueName: String?
    var username: String?
    var city: String?
    var age: Int?
    var sex: String?
    var school: String?
    
    // 需要做key的映射修改时才需要
    enum CodingKeys: String, CodingKey {
        case age = "age"
        case city = "city"
        case school = "school"
        case sex = "sex"
        case trueName = "truename"
        case username = "username"
    }
    
    // 可不实现，系统默认
//    required init(from decoder: Decoder) throws {
//        try super.init(from: decoder)
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        age = try container.decodeIfPresent(Int.self, forKey: .age)
//        city = try container.decodeIfPresent(String.self, forKey: .city)
//        school = try container.decodeIfPresent(String.self, forKey: .school)
//        sex = try container.decodeIfPresent(String.self, forKey: .sex)
//        trueName = try container.decodeIfPresent(String.self, forKey: .trueName)
//        username = try container.decodeIfPresent(String.self, forKey: .username)
//    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(age, forKey: .age)
        try container.encode(city, forKey: .city)
        try container.encode(school, forKey: .school)
        try container.encode(sex, forKey: .sex)
        try container.encode(trueName, forKey: .trueName)
        try container.encode(username, forKey: .username)
    }
}

class SiteModel: Codable {
    var name: String = ""
    var url: String = ""
}
