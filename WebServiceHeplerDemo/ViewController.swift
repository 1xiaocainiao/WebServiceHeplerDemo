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
//        requestBaiduAlertError()
        
        
//        requestBaiduAsync()
//        requestThrowingAsync()
//        requestCancelTaskAsync()
        
//        testNormalRequest()
        
//        testPublisherRequest()
        
//        testRefreshToken()
        
        
//        testDataBase()
        
//        requestModelPublisher()
        
        requestJsonPublisher()

        // Do any additional setup after loading the view.
    }
    
    func requestBaidu() {
        let api = TestRequestType.baidu
        let context = RequestContext(target: api, option: .toast)
        // 不传context默认是toast
        LXWebServiceHelper<UserInfo>().requestJSONModel(api, context: context, progressBlock: nil) { result in
            switch result {
            case .success(let container):
                printl(message: container.value?.trueName)
            case .failure(let error):
                printl(message: "出错了")
            }
        }
    }
    
    func requestBaiduAlertError() {
        let api = TestRequestType.baidu
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { action in
            printl(message: "取消")
        }
        let retryAction = UIAlertAction(title: "重试", style: .default) { action in
            printl(message: "重试")
        }
        let context = RequestContext(target: api, option: .alertWithAction, alertActions: [cancelAction, retryAction])
        // 不传context默认是toast
        LXWebServiceHelper<UserInfo>().requestJSONModel(api, context: context, progressBlock: nil) { result in
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

extension ViewController {
    func requestModelPublisher() {
        let publisher = LXWebServiceHelper<CityInfo>().requestJSONModelPublisher(TestRequestType.cityTest)
        publisher.sink { completion in
            switch completion {
            case .finished:
                printl(message: "finished")
            case .failure(let error):
                printl(message: error.localizedDescription)
            }
        } receiveValue: { container in
            printl(message: container.value?.city)
        }.store(in: &cancellables)
    }
    
    func requestJsonPublisher() {
        let publisher = LXWebServiceHelper<CityInfo>().requestJSONRawObjectPublisher(TestRequestType.cityTest)
        publisher.sink { completion in
            switch completion {
            case .finished:
                printl(message: "finished")
            case .failure(let error):
                printl(message: error.localizedDescription)
            }
        } receiveValue: { result in
            printl(message: "json: \(result)")
        }.store(in: &cancellables)
    }
}
