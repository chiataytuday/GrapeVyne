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
        var counter = 0
        super.viewDidAppear(animated)
        loadCategories(completion: { categoryArray in
            var array = [Category]()
            for category in categoryArray {
                self.checkValidityFor(category: category, completion: { flag in
                    counter += 1
                    if flag {
                        array.append(category)
                    }
                    if counter == categoryArray.count {
                        categoryRepo.arrayOfCategories = array.sorted(by: {$0.title < $1.title})
                        categoryRepo.writeCategoryToCD(array: categoryRepo.arrayOfCategories)
                        let landingVC = self.storyboard?.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
                        self.present(landingVC, animated: true, completion: nil)
                    }
                })
            }
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
    
//    private func loadValidCategories(array: [Category], completion: @escaping (_ array: [Category]) -> Void) {
//        for category in array {
//            network.getStoriesFor(category: , completion: )
//            network.isValidCategory(category: category, completion: {bool in
//                if bool {
//                    categoryRepo.arrayOfCategories.append(category)
//                }
//            })
//        }
//        categoryRepo.writeCategoryToCD(array: categoryRepo.arrayOfCategories)
//        completion()
//    }
}
