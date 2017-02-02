//
//  Network.swift
//  StoryApp
//
//  Created by Umair Sharif on 1/28/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import Foundation

class Network {
    
    public func makeRequest(token : ProjectToken) -> Data {
        
        let url = URL(string: "https://www.parsehub.com/api/v2/projects/\(token.rawValue)/last_ready_run/data?api_key=t_mLCwaTNSTu")
        var data : Data?
        var error : Error?
        
        (data, _, error) = URLSession.shared.synchronousDataTask(with: url!)
        if (error != nil) {
            print(error.debugDescription)
            data = nil
        } else {
            switch token {
            case .trueProject:
                UserDefaultsManager.trueData = data!
            case .falseProject:
                UserDefaultsManager.falseData = data!
            }
            UserDefaultsManager.hasNetworkData = true
        }
        return data!
    }
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

enum ProjectToken : String {
    case falseProject = "t9eT0c4yuFGf"
    case trueProject = "tKWsPC0omVB4"
}
