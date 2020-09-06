//
//  NetworkManager.swift
//  TimeDisableHotWater
//
//  Created by Vadim Denisov on 03.09.2020.
//  Copyright © 2020 Vadim Denisov. All rights reserved.
//

import Foundation
import Alamofire
import Zip

final class NetworkManager {

    enum NetworkError: Error {
        case success, failure, canceled, unknown
    }
    
    static let shared = NetworkManager()
    
    private init() { }
    
    private let queue = DispatchQueue(label: "Network Manager Queue", qos: .utility)
    
    private let hostname = "https://api.gu.spb.ru"

    
    @discardableResult
    func fetchClassfiers(completion: @escaping ([Classifier]?, NetworkError) -> Void) -> DataRequest {
        let path = "/UniversalMobileService/classifiers/downloadClassifiers?classifiersId=4"
        
        return AF.request(hostname + path, method: .get).validate().responseDecodable(of: ClassifierResponse.self, queue: queue) { response in
            switch response.result {
            case .success(let classifierResponse):
                DispatchQueue.main.async {
                    completion(classifierResponse.responseData.classifiers, .success)
                }
            case .failure(let error as NSError):
                if error.domain == NSURLErrorDomain, error.code == NSURLErrorCancelled {
                    DispatchQueue.main.async {
                        completion(nil, .canceled)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, .failure)
                    }
                }
            }
        }
    }
    
}
