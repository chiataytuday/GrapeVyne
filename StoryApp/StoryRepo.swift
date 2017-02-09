//
//  StoryRepo.swift
//  StoryApp
//
//  Created by Umair Sharif on 12/30/16.
//  Copyright © 2016 usharif. All rights reserved.
//
import UIKit
import CoreData

class StoryRepo {
    var arrayOfStories : [Story]

    init() {
        arrayOfStories = []
    }
    
    func appendTitlesAsStories(array : [String], fact : Bool) {
        for string in array {
            if !string.isEmpty {
                if !(string.characters.count < 10) {
                    arrayOfStories.append(Story(title: string, fact: fact))
                    CoreDataManager.writeStoryToModel(entity: "CDStory", title: string, fact: fact)
                }
            }
        }
    }
    
}
