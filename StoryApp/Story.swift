//
//  Story.swift
//  StoryApp
//
//  Created by Umair Sharif on 12/30/16.
//  Copyright © 2016 usharif. All rights reserved.
//

class Story {
    var title : String
    var fact : Bool
    var urlString : String
    
    init(title: String, fact: Bool, urlStr: String) {
        self.title = title
        self.fact = fact
        self.urlString = urlStr
    }
}
