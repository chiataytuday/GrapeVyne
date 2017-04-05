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
        loadCategories(completion: {
            let landingVC = self.storyboard?.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
            self.present(landingVC, animated: true, completion: nil)
        })
    }
    
    private func loadCategories(completion: @escaping () -> Void) {
        let managedObject = CoreDataManager.fetchModel(entity: "CDCategory")
        if managedObject.isEmpty {
            //Nothing in Core Data
            network.getCategories(completion: { categories in
                categoryRepo.arrayOfCategories = categories
                categoryRepo.writeCategoryToCD(array: categories)
                completion()
            })
        } else {
            //Something in Core Data
            for object in managedObject {
                let title = object.value(forKey: "title") as! String
                let urlString = object.value(forKey: "urlString") as! String
                let tempCategory = Category(title: title, url: urlString)
                categoryRepo.arrayOfCategories.append(tempCategory)
            }
            completion()
        }
    }
}
