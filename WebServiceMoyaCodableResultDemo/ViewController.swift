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
        
        testPublisherRequest()
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

    func testPublisherRequest() {
        let publisher = LXWebServiceHelper<CityInfo>().requestJsonModelPublisher(TestRequestType.cityTest, progressBlock: nil)
        
        
//        publisher.sink { completion in
//            switch completion {
//            case .finished:
//                printl(message: "finished")
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
//        } receiveValue: { container in
//            printl(message: container.value?.city)
//        }.store(in: &cancellables)
          
        
        publisher.sink { reuslt in
            switch reuslt {
            case .success(let container):
                printl(message: container.value?.city)
            case .failure(let error):
                printl(message: error.localizedDescription)
                guard let error = error as? LXError else {
                    return
                }
                if case .serverDataFormatError = error {
                    printl(message: "缺失状态码")
                }
                if case .dataContentTransformToModelFailed = error {
                    printl(message: "json to model failed")
                }
            }
        }.store(in: &cancellables)
    }

}

