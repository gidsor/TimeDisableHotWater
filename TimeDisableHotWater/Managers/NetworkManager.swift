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

enum NetworkError: Error {
    case success, failure, canceled, unknown
}

class NetworkManager {
    
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
                completion(classifierResponse.responseData.classifiers, .success)
            case .failure(let error as NSError):
                if error.domain == NSURLErrorDomain, error.code == NSURLErrorCancelled {
                    completion(nil, .canceled)
                } else {
                    completion(nil, .failure)
                }
            }
        }
    }
    
    func fetchSchedules(classifier: Classifier, completion: @escaping ([Schedule]?) -> Void) {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
        let zipPath = directory.appendingPathComponent("archive.zip")
        
        let data = Data(base64Encoded: classifier.zipFileBase64Encoded)
        try? data?.write(to: zipPath)
        
        try? Zip.unzipFile(zipPath, destination: directory, overwrite: true, password: nil, progress: nil) { (unzipedFilePath) in
            guard let str = try? String(contentsOfFile: unzipedFilePath.absoluteString), let data = str.data(using: .utf8) else {
                completion(nil)
                return
            }
            
            let schedules = try? JSONDecoder().decode(Array<Schedule>.self, from: data)
            completion(schedules)
        }
    }
    
}
