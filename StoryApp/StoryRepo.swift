//
//  StoryRepo.swift
//  StoryApp
//
//  Created by Umair Sharif on 12/30/16.
//  Copyright © 2016 usharif. All rights reserved.
//

class StoryRepo {
    var arrayOfStories : [Story]
    
    init() {
        arrayOfStories = []
        arrayOfStories.append(Story(title: "Obama Fills Out Lukewarm Glassdoor Review After Exiting Presidency", fact: false))
        arrayOfStories.append(Story(title: "Trump eyes temporary ban on refugees", fact: true))
        arrayOfStories.append(Story(title: "Steelers Players Make Surprise Hospital Visits To Spend Time With Opponents They’ve Injured", fact: false))
        arrayOfStories.append(Story(title: "Three arrested in Sweden over 'gang rape' on Facebook Live", fact: true))
        arrayOfStories.append(Story(title: "Man Bragging About How Infrequently He Receives Dental Care", fact: false))
        arrayOfStories.append(Story(title: "Elon Musk plans to start digging tunnels to beat traffic", fact: true))
        arrayOfStories.append(Story(title: "Ryan Gosling Sneaks Past Paparazzi In Full-Body Red Carpet Camouflage", fact: false))
        arrayOfStories.append(Story(title: "Madonna denies Malawian adoption reports", fact: true))
    }
}
