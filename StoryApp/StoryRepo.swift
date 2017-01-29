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
        let parsedJSON = jsonPar.parseTitles(json: networkCall.makeRequest())
        for str in parsedJSON {
            print(str.characters.count)
            if !str.isEmpty {
                if !(str.characters.count < 10) {
                    arrayOfStories.append(Story(title: str, fact: false))
                }
            }
        }
    }
