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
    var arrayOfCorrectStories : [Story]
    var arrayOfIncorrectStories : [Story]
    
    init() {
        arrayOfStories = []
        arrayOfCorrectStories = []
        arrayOfIncorrectStories = []
    }
    
    func writeToCD(array: [Story]) {
        for story in arrayOfStories {
            CoreDataManager.writeStoryToModel(entity: "CDStory", title: story.title, fact: story.fact, urlStr: story.urlString)
        }
    }
}
