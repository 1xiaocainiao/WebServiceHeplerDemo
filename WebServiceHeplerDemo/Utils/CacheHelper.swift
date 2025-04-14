

import Foundation

struct CachePropertyKey {
    static let gloableConfigKey: String = "gloableConfigKey"
}

class CacheHelper {
    static let `default` = CacheHelper()
    
    private func `init`() {
        
    }
    
    func set<T: Codable>(_ object: T?, forkey key: String) {
        if let data = try? JSONEncoder().encode(object) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: key)
            userDefaults.synchronize()
        }
    }
    
    func object<T: Codable>(forkey key: String) -> T? {
        let userDefaults = UserDefaults.standard
        if let value = userDefaults.object(forKey: key) as? Data,
           let resultValue = try? JSONDecoder().decode(T.self, from: value){
            return resultValue
        }
        return nil
    }
    
    func remove(forkey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

