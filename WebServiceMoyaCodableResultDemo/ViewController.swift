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
        LXWebServiceHelper<CityInfo>().requestJSONModel(TestRequestType.cityTest, progressBlock: nil) { result in
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
            let dbPath = "path/to/database.sqlite"
            let dbManager = DatabaseManager(path: dbPath)
            
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
            try dbManager.insert(user)
            
            let temp = try dbManager.query(User(), where: "id = 1")
            print(temp)
            
            // 查询数据
//            let users = try dbManager.query(User.self, where: "id = 1")
//            print(users)
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

