//
//  APICaller.swift
//  Combine Demo
//
//  Created by Yvan Feng on 2021/6/19.
//

import Foundation
import Combine

class APICaller {
    static let shared = APICaller()
    
    /// 接口获取数据
    func fetchData() -> Future<[String], Error> {
        return Future { promise in
            //模拟网络请求，2秒后返回数据
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                promise(.success(["Apple", "Google", "Microsoft", "Facebook"]))
            }
        }
    }
    
}
