//
//  JSONParser.swift
//  StoryApp
//
//  Created by Umair Sharif on 1/28/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import SwiftyJSON

class JSONParser {
    public func parseStories(data : Data) -> [Story] {
        let jsonResponse = JSON(data: data)
        var arrayOfStories = [Story]()
        for i in 0..<jsonResponse["articles"].count {
            let title = jsonResponse["articles"][i]["title"].string!
            if jsonResponse["articles"][i]["fact"].string! == "mixture" || jsonResponse["articles"][i]["fact"].string! == "undetermined" || jsonResponse["articles"][i]["fact"].string! == "legend" {
                continue
            }
            let factString = jsonResponse["articles"][i]["fact"].string!
            let factAsBool = factString.toBool()
            let url = jsonResponse["articles"][i]["url"].string!
            arrayOfStories.append(Story(title: title, fact: factAsBool!, urlStr: url))
        }
        return arrayOfStories
    }
}
extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "mtrue":
            return true
        case "False", "false", "mfalse":
            return false
        default:
            return false
        }
    }
}

