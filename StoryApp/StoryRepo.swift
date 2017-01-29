//
//  StoryRepo.swift
//  StoryApp
//
//  Created by Umair Sharif on 12/30/16.
//  Copyright © 2016 usharif. All rights reserved.
//

class StoryRepo {
    var arrayOfStories : [Story]
    let networkCall = Network()
    var jsonPar = JSONParser()
    
    init() {
        arrayOfStories = []
        var j = networkCall.makeRequest()
        //var parsedJSON = jsonPar.parse(json: networkCall.makeRequest())
        var parsedJSON = ["1", "2"]
        for str in parsedJSON {
            if !str.isEmpty {
                arrayOfStories.append(Story(title: str, fact: false))
            }
        }
    }
}
