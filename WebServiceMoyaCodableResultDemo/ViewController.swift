//
//  ViewController.swift
//  WebServiceMoyaCodableResultDemo
//
//  Created by mac on 2024/10/14.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        LXWebServiceHelper<UserInfo>().requestJSONModel(TestRequestType.baidu, progressBlock: nil) { result in
//            switch result {
//            case .success(let container):
//                printl(message: container.value?.trueName)
//            case .failure(let error):
//                printl(message: "出错了")
//            }
//        }
        
//        testNormalRequest()
        
//        testPublisherRequest()
        
//        testRefreshToken()
        
        
        testDataBase()

        // Do any additional setup after loading the view.
    }
    
    func testNormalRequest() {
        let helper = LXWebServiceHelper<CityInfo>()
        helper.toastHandler = { error in
            return (autoShow: true, type: .toast)
        }
        helper.requestJSONModel(TestRequestType.cityTest, progressBlock: nil) { result in
            switch result {
            case .success(let container):
                printl(message: container.value?.city)
            case .failure(let error):
                printl(message: "出错了")
            }
        }
    }
    
    func testDataBase() {
        do {
            let dbManager = DatabaseManager()
            
            // 创建表
            try dbManager.createTable(User())
            
            // 插入数据
            let profile = Profile()
            profile.age = 25
            profile.email = "test@example.com"
            let user = User()
            user.id = 1
            user.name = "张三 李四 王麻子"
            user.profile = [profile]
            user.isSelf = true
//            try dbManager.insert(user)
            
            _ = dbManager.deleteTable(from: User.tableName, otherSqlDic: [:])
            
            let temp = try dbManager.query(User(), where: "id = 1")
            print(temp)
            
        } catch {
            print("Error: \(error)")
        }
    }

//    func testPublisherRequest() {
//        let publisher = LXWebServiceHelper<CityInfo>().requestJsonModelPublisher(TestRequestType.cityTest, progressBlock: nil)
//        
//        
////        publisher.sink { completion in
////            switch completion {
////            case .finished:
////                printl(message: "finished")
////            case .failure(let error):
////                printl(message: error.localizedDescription)
////                guard let error = error as? LXError else {
////                    return
////                }
////                if case .serverDataFormatError = error {
////                    printl(message: "缺失状态码")
////                }
////                if case .dataContentTransformToModelFailed = error {
////                    printl(message: "json to model failed")
////                }
////            }
////        } receiveValue: { container in
////            printl(message: container.value?.city)
////        }.store(in: &cancellables)
//          
//        
//        publisher.sink { reuslt in
//            switch reuslt {
//            case .success(let container):
//                printl(message: container.value?.city)
//            case .failure(let error):
//                printl(message: error.localizedDescription)
//                guard let error = error as? LXError else {
//                    return
//                }
//                if case .serverDataFormatError = error {
//                    printl(message: "缺失状态码")
//                }
//                if case .dataContentTransformToModelFailed = error {
//                    printl(message: "json to model failed")
//                }
//            }
//        }.store(in: &cancellables)
//    }
    
    func testRefreshToken() {
//        for index in 0..<1 {
//            printl(message: "prepare request \(index)")
//            
//            RefreshTokenManager.default.checkAndRefreshTokenIfNeeded { finish in
//                printl(message: "refresh token finish \(index)")
//            }
//            
//            printl(message: "prepare request finish \(index)")
//        }
    }

}

