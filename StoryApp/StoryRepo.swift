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
        getTitles(token: .falseProject)
        getTitles(token: .trueProject)
    }
    
    // MARK: Private fucntions
    
    func getTitles(token : ProjectToken) {
        var fact : Bool?
        if token == .falseProject {
            fact = false
        } else if token == .trueProject {
            fact = true
        }
        let parsedJSON = jsonPar.parseTitles(json: networkCall.makeRequest(token: token))
        for str in parsedJSON {
            if !str.isEmpty {
                if !(str.characters.count < 10) {
                    arrayOfStories.append(Story(title: str, fact: fact!))
                }
            }
        }
    }

}
