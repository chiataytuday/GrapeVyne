//
//  LaunchViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import RevealingSplashView

let snopesScrapeNetwork = SnopesScrapeNetwork()
let openTriviaDBNetwork = OpenTriviaDBNetwork()
let categoryRepo = CategoryRepo()
let storyRepo = StoryRepo()

class LaunchViewController: UIViewController {
    var revealingSplashView: RevealingSplashView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
        
        //Initialize a revealing Splash with with the iconImage, the initial size and the background color
        revealingSplashView = RevealingSplashView(iconImage: #imageLiteral(resourceName: "logo_icon"),
                                                      iconInitialSize: CGSize(width: 100, height: 100),
                                           backgroundColor: .black)
        revealingSplashView.animationType = .heartBeat
        
        //Adds the revealing splash view as a sub view
        self.view.addSubview(revealingSplashView)
        
        //Starts animation
        revealingSplashView.startAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openTriviaDBNetwork.getCategories(completion: {arrayOfCategories in
            categoryRepo.arrayOfOpenTriviaDBCategories = arrayOfCategories.sorted(by: {$0.title < $1.title})
            categoryRepo.arrayOfOpenTriviaDBCategories.insert(Category(title: "Random", id: nil, url: nil, stories: nil), at: 0)
            self.getCategories(completion: {
                self.revealingSplashView.playZoomOutAnimation()
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
