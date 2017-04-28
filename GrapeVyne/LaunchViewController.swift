//
//  LaunchViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

let snopesScrapeNetwork = SnopesScrapeNetwork()
let openTriviaDBNetwork = OpenTriviaDBNetwork()
let categoryRepo = CategoryRepo()
let storyRepo = StoryRepo()

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openTriviaDBNetwork.getCategories(completion: {arrayOfCategories in
            categoryRepo.arrayOfOpenTriviaDBCategories = arrayOfCategories.sorted(by: {$0.title < $1.title})
            categoryRepo.arrayOfOpenTriviaDBCategories.insert(Category(title: "Random", id: nil, url: nil, stories: nil), at: 0)
            self.getCategories(completion: {
                let landingVC = self.storyboard?.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
                self.present(landingVC, animated: true, completion: nil)
            })
        })
    }
    
    private func getCategories(completion: @escaping () -> Void) {
        snopesScrapeNetwork.getCategories(completion: { arrayOfCategories in
            self.loadValidCategories(array: arrayOfCategories, completion: { arrayOfValidCategories in
                categoryRepo.arrayOfSnopesCategories = arrayOfValidCategories.sorted(by: {$0.title < $1.title})
                completion()
            })
        })
    }
    
    private func loadValidCategories(array: [Category], completion: @escaping (_ array: [Category]) -> Void) {
        var counterToComplete = 0
        var completeArray = [Category]()
        for category in array {
            snopesScrapeNetwork.isValidCategory(category: category, completion: {bool in
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
