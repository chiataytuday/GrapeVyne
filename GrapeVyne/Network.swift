//
//  Network.swift
//  StoryApp
//
//  Created by Umair Sharif on 1/28/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

class MockedJSON {
   static public func getData() -> Data {
    var data = Data()
        if let path = Bundle.main.path(forResource: "articles", ofType: "json") {
            do {
                data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    return data
    }
}

class Network {



}

extension URLSession {
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}
