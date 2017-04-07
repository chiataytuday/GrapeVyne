//
//  LaunchViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

var storyRepo = StoryRepo()
var categoryRepo = CategoryRepo()

class LaunchViewController: UIViewController {
    let network = Network()
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCategories(completion: { categoryArray in
            self.loadValidCategories(array: categoryArray, completion: { validCategories in
                categoryRepo.arrayOfCategories = validCategories.sorted(by: {$0.title < $1.title})
                categoryRepo.writeCategoryToCD(array: categoryRepo.arrayOfCategories)
                let landingVC = self.storyboard?.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
                self.present(landingVC, animated: true, completion: nil)
            })
        })
    }
    
    private func loadCategories(completion: @escaping (_ array: [Category]) -> Void) {
        let managedObject = CoreDataManager.fetchModel(entity: "CDCategory")
        if managedObject.isEmpty { //Nothing in Core Data
            network.getCategories(completion: { array in
                completion(array)
            })
        } else { //Something in Core Data
            var tempArray = [Category]()
            for object in managedObject {
                let title = object.value(forKey: "title") as! String
                let urlString = object.value(forKey: "urlString") as! String
                let tempCategory = Category(title: title, url: urlString)
                tempArray.append(tempCategory)
            }
            completion(tempArray)
        }
    }
    
    private func checkValidityFor(category: Category, completion: @escaping (_ flag: Bool) -> Void) {
        network.getStoriesFor(category: category, completion: { array in
            if array.count > 0 {
                completion(true)
            } else {
                completion(false)
            }
        })
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
