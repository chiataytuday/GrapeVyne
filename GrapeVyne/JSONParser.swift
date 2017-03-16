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
            if arrayOfStories.contains(where: {$0.title == title}) {
                // if the story is already in the array of stories, i.e duplicate stories
                continue
            }
            let factString = jsonResponse["articles"][i]["fact"].string!
            let isStoryReliable = determineStoryReliable(factString: factString)
            if isStoryReliable == nil {
                continue
            }
            let factAsBool = isStoryReliable!
            let url = jsonResponse["articles"][i]["url"].string!
            arrayOfStories.append(Story(title: title, fact: factAsBool, urlStr: url))
        }
        return arrayOfStories
    }
    
    private func determineStoryReliable(factString: String) -> Bool? {
        switch factString {
        case "True", "true", "mtrue":
            return true
        case "False", "false", "mfalse":
            return false
        default:
            return nil
        }
    }
}

