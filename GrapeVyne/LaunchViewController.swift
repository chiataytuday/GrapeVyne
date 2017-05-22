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
import ReachabilitySwift
import PopupDialog

let reachability = Reachability()!
let snopesScrapeNetwork = SnopesScrapeNetwork()
let categoryRepo = CategoryRepo()
let storyRepo = StoryRepo()

class LaunchViewController: UIViewController {
    var revealingSplashView: RevealingSplashView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
        
        revealingSplashView = RevealingSplashView(iconImage: #imageLiteral(resourceName: "logo_icon"),
                                                  iconInitialSize: CGSize(width: 100, height: 100),
                                                  backgroundColor: .black)
        revealingSplashView.animationType = .heartBeat
        self.view.insertSubview(revealingSplashView, belowSubview: loadingLabel)
        //self.view.addSubview(revealingSplashView)
        
        loadingLabel.attributedText = NSAttributedString(string: "Loading database,\n please do not navigate away".uppercased(),
                                                                 attributes: [NSFontAttributeName: UIFont(name: "Gotham-Bold", size: 22.0)!,
                                                                              NSForegroundColorAttributeName: UIColor.white])
        loadingLabel.numberOfLines = 2
        loadingLabel.textAlignment = .center
        loadingLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let popupDialog = PopupDialog(title: "Network Error!".uppercased(),
                                      message: "Please check your internet connection and try again.".uppercased(),
                                      image: nil, buttonAlignment: .horizontal,
                                      transitionStyle: .fadeIn, gestureDismissal: false,
                                      completion: nil)
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.backgroundColor      = CustomColor.customPurple
        dialogAppearance.titleFont            = UIFont(name: "Gotham-Bold", size: 22.0)!
        dialogAppearance.titleColor           = .white
        dialogAppearance.titleTextAlignment   = .center
        dialogAppearance.messageFont          = UIFont(name: "Gotham-Bold", size: 14.0)!
        dialogAppearance.messageColor         = .white
        dialogAppearance.messageTextAlignment = .center
        
        let pcv = PopupDialogContainerView.appearance()
        pcv.cornerRadius = 15
        
        reachability.whenReachable = { reachability in
            popupDialog.dismiss(animated: true, completion: nil)
        }
        
        reachability.whenUnreachable = { reachability in
            self.present(popupDialog, animated: true, completion: nil)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        revealingSplashView.startAnimation()
        if reachability.isReachable {
            Async.userInitiated({
                storyRepo.arrayOfStories = snopesScrapeNetwork.prepareDB()
            }).main({
                self.loadingLabel.isHidden = true
                self.revealingSplashView.playZoomOutAnimation({
                    let landingVC = self.storyboard?.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
                    self.present(landingVC, animated: true, completion: nil)
                })
            })
        }
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
