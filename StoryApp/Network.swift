//
//  Network.swift
//  StoryApp
//
//  Created by Umair Sharif on 1/28/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import SwiftyJSON

class Network {
    
    public func makeRequest() {
        var request = URLRequest(url: URL(string: "https://www.parsehub.com/api/v2/projects/t9eT0c4yuFGf/last_ready_run/data?api_key=t_mLCwaTNSTu")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        var jsonResponse : JSON?
        session.dataTask(with: request) {data, response, error in
            if(error != nil) {
                print("error")
            } else {
                jsonResponse = JSON(data: data!)
                print(jsonResponse!)
            }
            }.resume()
        //return jsonResponse!
    }
}
