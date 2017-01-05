//
//  Story.swift
//  StoryApp
//
//  Created by Umair Sharif on 12/30/16.
//  Copyright © 2016 usharif. All rights reserved.
//

class Story {
    var name : String?
    var text : String?
    var fact : Bool?
    
    init(name:String, text:String, fact: Bool) {
        self.name = name
        self.text = text
        self.fact = fact
    }
}
