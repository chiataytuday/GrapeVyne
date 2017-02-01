//
//  Network.swift
//  StoryApp
//
//  Created by Umair Sharif on 1/28/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import SwiftyJSON

class Network {
    public let FALSE_PROJECT_TOKEN = "t9eT0c4yuFGf"
    public let TRUE_PROJECT_TOKEN = "t0744QDN9fDV"
    
    public func makeRequest(token : ProjectToken) -> JSON {
        
        let url = URL(string: "https://www.parsehub.com/api/v2/projects/\(token.rawValue)/last_ready_run/data?api_key=t_mLCwaTNSTu")
        var data : Data?
        var error : Error?
        
        
        var jsonResponse : JSON?
        (data, _, error) = URLSession.shared.synchronousDataTask(with: url!)
        if (error != nil) {
            print(error.debugDescription)
        } else {
            jsonResponse = JSON(data: data!)
        }
        return jsonResponse!
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
    case trueProject = "t0744QDN9fDV"
}
