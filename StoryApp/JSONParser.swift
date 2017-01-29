//
//  JSONParser.swift
//  StoryApp
//
//  Created by Umair Sharif on 1/28/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import SwiftyJSON

class JSONParser {
    public func parse(json : JSON) -> [String] {
        var array = [String]()
        for i in 0..<json["categories"].count {
            for j in 0..<json["categories"][i].count {
                array.append(json["categories"][i]["articles"][j]["title"].stringValue)
            }
        }
        return array
    }
}

