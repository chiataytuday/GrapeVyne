//
//  Repository.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 4/4/17.
//  Copyright © 2017 usharif. All rights reserved.
//
import CoreData

class StoryRepo {
    var arrayOfStories : [Story]
    var arrayOfSwipedStories : [Story]
    var arrayOfCorrectStories : [Story]
    var arrayOfIncorrectStories : [Story]
    
    init() {
        arrayOfStories = []
        arrayOfSwipedStories = []
        arrayOfCorrectStories = []
        arrayOfIncorrectStories = []
    }
    
    func writeToCD(array: [Story]) {
        for story in arrayOfStories {
            CoreDataManager.writeStoryToModel(entity: "CDStory", title: story.title, fact: story.fact, urlStr: story.url)
        }
    }
}
class CategoryRepo {
    var arrayOfCategories: [Category]
    
    init() {
        arrayOfCategories = []
    }
}

struct Category {
    var title: String
    var url: String
}
struct Story {
    var title: String
    var url: String
    var fact: Bool
}
