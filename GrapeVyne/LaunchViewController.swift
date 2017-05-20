//
//  LaunchViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import RevealingSplashView
import Async

let snopesScrapeNetwork = SnopesScrapeNetwork()
let categoryRepo = CategoryRepo()
let storyRepo = StoryRepo()

class LaunchViewController: UIViewController {
    var revealingSplashView: RevealingSplashView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
        
        revealingSplashView = RevealingSplashView(iconImage: #imageLiteral(resourceName: "logo_icon"),
                                                  iconInitialSize: CGSize(width: 100, height: 100),
                                                  backgroundColor: .black)
        revealingSplashView.animationType = .heartBeat
        self.view.addSubview(revealingSplashView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        revealingSplashView.startAnimation()
        Async.userInitiated({
            snopesScrapeNetwork.prepareDB()
            Async.main({
                self.revealingSplashView.playZoomOutAnimation({
                    let landingVC = self.storyboard?.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
                    self.present(landingVC, animated: true, completion: nil)
                })
            })
        })
    }
    
    private func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for \(title): \(timeElapsed) s")
    }
    
    private func timeElapsedInSecondsWhenRunningCode(operation:()->()) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return Double(timeElapsed)
    }
    
}
