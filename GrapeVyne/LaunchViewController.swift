//
//  LaunchViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

let network = SnopesScrapeNetwork()
let categoryRepo = CategoryRepo()
let storyRepo = StoryRepo()

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getCategories(completion: {
            let landingVC = self.storyboard?.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
            self.present(landingVC, animated: true, completion: nil)
        })
    }
    
    private func getCategories(completion: @escaping () -> Void) {
        let arrayOfCDCategories = CoreDataManager.fetchModel(entity: "CDCategory") as! [CDCategory]
        if arrayOfCDCategories.isEmpty { // No Categories in Core Data
            network.getCategories(completion: { array in
                self.loadValidCategories(array: array, completion: { validCategories in
                    categoryRepo.arrayOfCategories = validCategories.sorted(by: {$0.title < $1.title})
                    categoryRepo.writeCategoriesToCD(array: categoryRepo.arrayOfCategories)
                    completion()
                })
            })
        } else { // Found categories in Core Data
            for category in arrayOfCDCategories {
                var arrayOfCategoryStories = [Story]()
                if let arrayOfCDStories = category.stories?.allObjects as? [CDStory] {
                    for _CDStory in arrayOfCDStories {
                        let title = _CDStory.title!
                        let url = _CDStory.urlString!
                        let fact = _CDStory.fact
                        let story = Story(title: title, url: url, fact: fact)
                        arrayOfCategoryStories.append(story)
                    }
                }
                let tempCategory = Category(title: category.title!, id: nil, url: category.urlString!, stories: arrayOfCategoryStories)
                categoryRepo.arrayOfCategories.append(tempCategory)
            }
            completion()
        }
    }
    
    private func loadValidCategories(array: [Category], completion: @escaping (_ array: [Category]) -> Void) {
        var counterToComplete = 0
        var completeArray = [Category]()
        for category in array {
            network.isValidCategory(category: category, completion: {bool in
                counterToComplete += 1
                if bool {
                    completeArray.append(category)
                }
                if counterToComplete == array.count {
                    completion(completeArray)
                }
            })
        }
    }
}
