//
//  ViewController.swift
//  WebServiceHeplerDemo
//
//  Created by mac on 2025/4/14.
//

import UIKit
import Combine

class ViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        requestBaidu()
        
        
//        requestBaiduAsync()
//        requestThrowingAsync()
        requestCancelTaskAsync()
        
//        testNormalRequest()
        
//        testPublisherRequest()
        
//        testRefreshToken()
        
        
//        testDataBase()

        // Do any additional setup after loading the view.
    }
    
    func requestBaidu() {
        let context = RequestContext(options: [.auto]) { error in
            printl(message: "自定义方法")
        }
        // 不传context默认是toast
        LXWebServiceHelper<UserInfo>().requestJSONModel(TestRequestType.baidu, context: context, progressBlock: nil) { result in
            switch result {
            case .success(let container):
                printl(message: container.value?.trueName)
            case .failure(let error):
                printl(message: "出错了")
            }
        }
    }
    
    func testNormalRequest() {
        let helper = LXWebServiceHelper<CityInfo>()
        helper.requestJSONModel(TestRequestType.cityTest, progressBlock: nil) { result in
            switch result {
            case .success(let container):
                printl(message: container.value?.city)
            case .failure(let error):
                printl(message: "出错了")
            }
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

// MARK: - async await
extension ViewController {
    func requestBaiduAsync() {
        Task {
            let result = await LXWebServiceHelper<UserInfo>().requestJSONModelAsync(TestRequestType.baidu)
            switch result {
            case .success(let container):
                printl(message: container.value?.trueName)
            case .failure(let error):
                printl(message: "出错了")
            }
        }
    }
    
    func requestThrowingAsync() {
        Task {
            do {
                let result = try await LXWebServiceHelper<UserInfo>().requestJSONModelThrowingAsync(TestRequestType.baidu)
                printl(message: result.value?.trueName)
            } catch {
                printl(message: "出错了")
            }
        }
    }
    
    func requestCancelTaskAsync() {
        let task = Task {
            do {
                let result = try await LXWebServiceHelper<UserInfo>().requestJSONRawObjectCancellableAsync(TestRequestType.baidu)
                printl(message: result)
            } catch {
                printl(message: "出错了")
            }
        }
        task.cancel()
    }
}
