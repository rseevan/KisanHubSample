//
//  Downloader.swift
//  KisanHubSample
//
//  Created by Seevan Ranka on 04/01/18.
//  Copyright © 2018 Seevan Ranka. All rights reserved.
//

import Foundation
class Downloader {
    class func load(url: URL, to localUrl: URL, completion: @escaping (URL) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    if FileManager.default.fileExists(atPath: localUrl.path){
                      try FileManager.default.removeItem(at: localUrl)
                    }
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    print("new location", tempLocalUrl.absoluteString)
                    completion(localUrl)
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                }
                
            } else {
                print("Failure: %@", error?.localizedDescription ?? "");
            }
        }
        task.resume()
    }
}
