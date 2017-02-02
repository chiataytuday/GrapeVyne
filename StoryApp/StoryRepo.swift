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
        if UserDefaultsManager.hasNetworkData {
            appendTitlesAsStories(array: jsonPar.parseTitles(data: UserDefaultsManager.trueData), fact: true)
            appendTitlesAsStories(array: jsonPar.parseTitles(data: UserDefaultsManager.falseData), fact: false)
        } else {
            appendTitlesAsStories(array: jsonPar.parseTitles(data: networkCall.makeRequest(token: .trueProject)), fact: true)
            appendTitlesAsStories(array: jsonPar.parseTitles(data: networkCall.makeRequest(token: .falseProject)), fact: false)
        }
    }
    
    // MARK: Private functions
    
    private func appendTitlesAsStories(array : [String], fact : Bool?) {
        for string in array {
            if !string.isEmpty {
                if !(string.characters.count < 10) {
                    arrayOfStories.append(Story(title: string, fact: fact!))
                }
            }
        }
    }
    
}
