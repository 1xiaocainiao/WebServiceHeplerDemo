

import Foundation
import CommonCrypto

let kPublicKey = "9A13AE6CAE4C1FF134F22F3B0953F0DA"
let kAESKey = "31FF1BAC33ABDC97"
let kAESIV = "ABDF4EB14FFAC1C1"
let KBaseURL = ""

func paramsEncrypt(params: [String: Any]) -> Data? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: params,
                                                  options: [])
        
        guard let encryptData = AES.default.encrypt(data: jsonData) else {
            return nil
        }
        
        return encryptData.base64EncodedData()
    } catch  {
        printl(message: "encrypt failed")
        return nil
    }
}

struct AES {
    
    static let `default` = AES()!
    
    private let key: Data
    private let iv: Data
    
     init?(key: String = kAESKey, iv: String = kAESIV) {
        guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES256, let keyData = key.data(using: .utf8) else {
            printl(message: "Error: failed to set a key")
            return nil
        }
        
        guard iv.count == kCCBlockSizeAES128, let ivData = iv.data(using: .utf8) else {
            printl(message: "Error: failed to set an initial vector.")
            return nil
        }
        
        self.key = keyData
        self.iv = ivData
    }
    
    func encrypt(data: Data) -> Data? {
        return crypt(data: data, option: CCOperation(kCCEncrypt))
    }
    
    func decrpty(data: Data) -> Data? {
        guard let decryptedData = crypt(data: data, option: CCOperation(kCCDecrypt)) else {
            return nil
        }
        return decryptedData
    }
    
    func decrypt(data: Data) -> String? {
        guard let decryptedData = decrpty(data: data) else {
            return nil
        }
        return String(bytes: decryptedData, encoding: .utf8)
    }
    
    func crypt(data: Data?, option: CCOperation) -> Data? {
        guard let data = data else {
            return nil
        }
        
        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData = Data(count: cryptLength)
        
        let keyLength = key.count
        let options = CCOptions(kCCOptionPKCS7Padding)
        
        var bytesLength = Int(0)
        
        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(option, CCAlgorithm(kCCAlgorithmAES), options, keyBytes.baseAddress, keyLength, ivBytes.baseAddress, dataBytes.baseAddress, data.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
                    }
                }
            }
        }
        
        
        guard UInt32(status) == UInt32(kCCSuccess) else {
            printl(message: "Error: Failed to crypt data. Status \(status)")
            return nil
        }
        
        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
}
