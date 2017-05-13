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
    
    func writeStoriesToCD(array: [Story]) {
        for story in array {
            CoreDataManager.writeToModel(story)
        }
    }
}
class CategoryRepo {
    var arrayOfSnopesCategories: [Category]
    var arrayOfOpenTriviaDBCategories: [Category]
    
    init() {
        arrayOfSnopesCategories = []
        arrayOfOpenTriviaDBCategories = []
    }
    
    func writeCategoriesToCD(array: [Category]) {
        for category in array {
            CoreDataManager.writeToModel(category)
        }
    }
}

struct Category {
    var title: String
    var id: Int?
    var url: String?
    var stories: [Story]?
}

struct Story {
    var title: String
    var url: String?
    var fact: Bool
}
