//
//  Classifier.swift
//  TimeDisableHotWater
//
//  Created by Vadim Denisov on 03.09.2020.
//  Copyright © 2020 Vadim Denisov. All rights reserved.
//

import Foundation
import Zip

struct Classifier: Decodable {
    
    let id: Int
    let name: String
    let version: String
    let zipFileBase64Encoded: String
        
    enum CodingKeys: String, CodingKey {
        case id = "classifierId"
        case name = "classifierName"
        case zipFileBase64Encoded = "file"
        case version = "version"
    }
}

struct ClassifierResponseData: Decodable {
    let classifiers: [Classifier]
}

struct ClassifierResponse: Decodable {
    let status: String
    let responseData: ClassifierResponseData
    let expectedResponseDate: String
}
