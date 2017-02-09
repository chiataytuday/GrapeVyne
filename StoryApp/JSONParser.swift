//
//  JSONParser.swift
//  StoryApp
//
//  Created by Umair Sharif on 1/28/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import SwiftyJSON

class JSONParser {
    public func parseStories(data : Data) -> [String] {
        let jsonResponse = JSON(data: data)
        var array = [String]()
        for i in 0..<jsonResponse["categories"].count {
            for j in 0..<jsonResponse["categories"][i]["articles"].count {
                array.append(jsonResponse["categories"][i]["articles"][j]["title"].stringValue)
            }
        }
        return array
    }
}

