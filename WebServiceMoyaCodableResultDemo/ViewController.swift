//
//  ViewController.swift
//  WebServiceMoyaCodableResultDemo
//
//  Created by mac on 2024/10/14.
//

import UIKit

class ViewController: UIViewController {

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
        
        LXWebServiceHelper<CityInfo>().requestJSONModel(TestRequestType.cityTest, progressBlock: nil) { result in
            switch result {
            case .success(let container):
                printl(message: container.value?.city)
            case .failure(let error):
                printl(message: "出错了")
            }
        }
        // Do any additional setup after loading the view.
    }


}

