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
import Reachability
import PopupDialog

let snopesScrapeNetwork = SnopesScrapeNetwork()
let categoryRepo = CategoryRepo()
let storyRepo = StoryRepo()

class LaunchViewController: UIViewController {
    let reachability = try? Reachability()
    let revealingSplashView = RevealingSplashView(iconImage: #imageLiteral(resourceName: "logo_icon"),
                                                  iconInitialSize: CGSize(width: 100, height: 100),
                                                  backgroundColor: .black)
    let loadingLabel = UILabel()
    let popupDialog = PopupDialog(title: "Network Error!".uppercased(),
                                  message: "Please check your internet connection and try again.".uppercased(),
                                  image: nil,
                                  buttonAlignment: .horizontal,
                                  transitionStyle: .fadeIn,
                                  tapGestureDismissal: false,
                                  completion: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
        loadSubviews()
        setupAutolayoutConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.global().async {
            storyRepo.arrayOfStories = snopesScrapeNetwork.prepareDB()
            
            DispatchQueue.main.sync { [weak self] in
                self?.loadingLabel.isHidden = true
                self?.revealingSplashView.playZoomOutAnimation({ [weak self] in
                    let landingVC = self?.storyboard?.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
                    self?.present(landingVC, animated: true, completion: nil)
                })
            }
        }
    }
    
    private func loadSubviews() {
//        loadPopupDialog()
        loadRevealingSplashView()
        loadLoadingLabel()
        loadReachability()
    }
    
    private func loadPopupDialog() {
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.backgroundColor      = CustomColor.customPurple
        dialogAppearance.titleFont            = UIFont(name: "Gotham-Bold", size: 22.0)!
        dialogAppearance.titleColor           = .white
        dialogAppearance.titleTextAlignment   = .center
        dialogAppearance.messageFont          = UIFont(name: "Gotham-Bold", size: 14.0)!
        dialogAppearance.messageColor         = .white
        dialogAppearance.messageTextAlignment = .center
        
        let pcv = PopupDialogContainerView.appearance()
        pcv.translatesAutoresizingMaskIntoConstraints = false
        pcv.cornerRadius = 15
        
        view.addSubview(pcv)
    }
    
    private func loadRevealingSplashView() {
        revealingSplashView.translatesAutoresizingMaskIntoConstraints = false
        revealingSplashView.animationType = .heartBeat
        view.addSubview(revealingSplashView)
        revealingSplashView.startAnimation()
    }
    
    private func loadLoadingLabel() {
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.attributedText = NSAttributedString(string: "Loading database,\n please do not navigate away".uppercased(),
                                                         attributes: [NSAttributedString.Key.font: UIFont(name: "Gotham-Bold", size: 22.0)!,
                                                                      NSAttributedString.Key.foregroundColor: UIColor.white])
        loadingLabel.numberOfLines = 2
        loadingLabel.textAlignment = .center
        loadingLabel.adjustsFontSizeToFitWidth = true
        loadingLabel.isHidden = false
        view.addSubview(loadingLabel)
    }
    
    private func loadReachability() {
        reachability?.whenReachable = { [weak self] reachability in
            self?.popupDialog.dismiss(animated: true, completion: nil)
        }
        
        reachability?.whenUnreachable = { reachability in
            self.present(self.popupDialog, animated: true, completion: nil)
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    private func setupAutolayoutConstraints() {
        setupRevealingSplashViewConstraints()
        setupLoadingLabelViewConstraints()
    }
    
    private func setupRevealingSplashViewConstraints() {
        revealingSplashView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        revealingSplashView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        revealingSplashView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    private func setupLoadingLabelViewConstraints() {
        loadingLabel.topAnchor.constraint(equalTo: revealingSplashView.bottomAnchor).isActive = true
        loadingLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        loadingLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        loadingLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
