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
            CoreDataManager.writeStoryToModel(entity: "CDStory", title: story.title, fact: story.fact, urlStr: story.urlString)
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
    var factValue: String?
}
