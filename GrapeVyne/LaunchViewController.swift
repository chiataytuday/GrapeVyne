//
//  LaunchViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

var storyRepo = StoryRepo()

class LaunchViewController: UIViewController {
    let jsonParser = JSONParser()

    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCards()
        let landingVC = (storyboard?.instantiateViewController(withIdentifier: "LandingViewController"))! as UIViewController
        landingVC.modalTransitionStyle = self.modalTransitionStyle
        present(landingVC, animated: true, completion: nil)
    }
    
    private func loadCards() {
        let managedObject = CoreDataManager.fetchModel(entity: "CDStory")
        if managedObject.isEmpty {
            //Nothing in Core Data
            print("Time taken to parse JSON: ",timeElapsedInSecondsWhenRunningCode {
                let stories = jsonParser.parseStories(data: MockedJSON.getData())
                storyRepo.arrayOfStories = stories
                storyRepo.writeToCD(array: stories)
            })
        } else {
            //Something in Core Data
            for object in managedObject {
                let title = object.value(forKey: "title") as! String
                let factValue = object.value(forKey: "fact") as! Bool
                let urlString = object.value(forKey: "urlString") as! String
                let tempStory = Story(title: title, fact: factValue, urlStr: urlString)
                storyRepo.arrayOfStories.append(tempStory)
            }
        }
        print("*** Number of stories currently in memory \(storyRepo.arrayOfStories.count) ***")
    }
    
    private func timeElapsedInSecondsWhenRunningCode(operation:()->()) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return Double(timeElapsed)
    }
}
