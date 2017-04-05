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
    
    func writeStoryToCD(array: [Story]) {
        for story in array {
            CoreDataManager.writeStoryToModel(entity: "CDStory", title: story.title, fact: story.fact, urlStr: story.url)
        }
    }
}
class CategoryRepo {
    var arrayOfCategories: [Category]
    
    init() {
        arrayOfCategories = []
    }
    
    func writeCategoryToCD(array: [Category]) {
        for category in array {
            CoreDataManager.writeCategoryToModel(entity: "CDCategory", title: category.title, urlStr: category.url)
        }
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
