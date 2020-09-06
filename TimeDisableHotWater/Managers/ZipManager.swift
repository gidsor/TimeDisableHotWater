//
//  ZipManager.swift
//  TimeDisableHotWater
//
//  Created by Vadim Denisov on 06.09.2020.
//  Copyright © 2020 Vadim Denisov. All rights reserved.
//

import Foundation
import Zip

final class ZipManager {
    
    private init() { }
    
    static func unzip(base64Encoded: String, completion: @escaping (Data?) -> Void) {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
        let zipPath = directory.appendingPathComponent("archive.zip")
        
        let data = Data(base64Encoded: base64Encoded)
        try? data?.write(to: zipPath)
        
        try? Zip.unzipFile(zipPath, destination: directory, overwrite: true, password: nil, progress: nil) { (unzipedFilePath) in
            guard let str = try? String(contentsOfFile: unzipedFilePath.absoluteString), let data = str.data(using: .utf8) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
    
}
