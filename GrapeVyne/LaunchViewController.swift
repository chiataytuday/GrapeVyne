//
//  LaunchViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

let network = Network()
var storyRepo = StoryRepo()
var categoryRepo = CategoryRepo()

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
        let managedObject = CoreDataManager.fetchModel(entity: "CDCategory")
        if managedObject.isEmpty { //Nothing in Core Data
            network.getCategories(completion: { array in
                self.loadValidCategories(array: array, completion: { validCategories in
                    categoryRepo.arrayOfCategories = validCategories.sorted(by: {$0.title < $1.title})
                    categoryRepo.writeCategoriesToCD(array: categoryRepo.arrayOfCategories)
                    completion()
                })
            })
        } else { //Something in Core Data
            var tempArray = [Category]()
            for object in managedObject {
                let title = object.value(forKey: "title") as! String
                let urlString = object.value(forKey: "urlString") as! String
                let stories = object.mutableSetValue(forKey: "stories") as? [Story]
                let tempCategory = Category(title: title, url: urlString, stories: stories)
                tempArray.append(tempCategory)
            }
            categoryRepo.arrayOfCategories = tempArray
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
