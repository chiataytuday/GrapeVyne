//
//  LandingViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import TKSubmitTransitionSwift3
import DGRunkeeperSwitch
import Async
import PickerView

class LandingViewController: UIViewController {
    let landingCornerRadius: CGFloat = 12.5
    let numberOfStoriesOpenTrivia = 20
    var selectedRow: Int?
    var prompt = SwiftPromptsView()
    var playLabel: UILabel!
    @IBOutlet weak var playButton: TKTransitionSubmitButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
        
        playButton.backgroundColor = CustomColor.customPurple
        playButton.spinnerColor = CustomColor.customGreen
        playButton.normalCornerRadius = 25
        
        playLabel = UILabel(frame: CGRect(x: 0, y: 0, width: playButton.bounds.size.width, height: playButton.bounds.size.height))
        playLabel.center = CGPoint(x: playButton.bounds.size.width / 2.0, y: playButton.bounds.size.height / 2.0)
        playLabel.textAlignment = .center
        playLabel.attributedText = NSAttributedString(string: "Play".uppercased(), attributes: [NSFontAttributeName : UIFont(name: "Gotham-Bold", size: 40.0)!])
        playLabel.textColor = .white
        playButton.addSubview(playLabel)
    }
    
    @IBAction func questionButton(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let viewTutorialAction = UIAlertAction(title: "How To Play", style: .default, handler: {presentVC in
            let instructionVC = self.storyboard?.instantiateViewController(withIdentifier: "InstructionViewController") as! InstructionViewController
            self.present(instructionVC, animated: true, completion: nil)
        })
        
        let viewCreditsAction = UIAlertAction(title: "Credits", style: .default, handler: {presentVC in
            let creditsVC = self.storyboard?.instantiateViewController(withIdentifier: "CreditsViewController") as! CreditsViewController
            self.present(creditsVC, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(viewTutorialAction)
        optionMenu.addAction(viewCreditsAction)
        optionMenu.addAction(cancelAction)
        
        optionMenu.view.tintColor = CustomColor.customPurple
        present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        //view.isUserInteractionEnabled = false
        didStartLoading()
        storyRepo.arrayOfStories = [Story]()
  
        Async.userInitiated({
            while storyRepo.arrayOfStories.count < 30 {
                var randBool = self.randomBool()
                for story in snopesScrapeNetwork.arrayOfParsedStories {
                    if story.fact == randBool {
                        let s = story
                        if let index = snopesScrapeNetwork.arrayOfParsedStories.index(where: {$0.title == story.title}) {
                            snopesScrapeNetwork.arrayOfParsedStories.remove(at: index)
                        }
                        storyRepo.arrayOfStories.append(s)
                        randBool = self.randomBool()
                    }
                }
            }
            Async.main({
                self.leaveViewController()
            })
        })
    }
    
    private func randomBool() -> Bool {
        print(arc4random_uniform(2) == 0)
        return arc4random_uniform(2) == 0
    }
    
    
    private func presentCustomAlertViewControllerFor(category: Category?) {
        self.view.isUserInteractionEnabled = true
        prompt = SwiftPromptsView(frame: self.view.bounds)
        
        prompt.setColorWithTransparency(color: .clear)
        
        prompt.setPromptHeight(height: 0.35 * (view.frame.height))
        prompt.setPromptWidth(width: 0.75 * (view.frame.width))
        
        prompt.setPromptButtonDividerVisibility(dividerVisibility: false)
        prompt.setPromptTopLineVisibility(topLineVisibility: false)
        prompt.setPromptBackgroundColor(backgroundColor: CustomColor.customPurple)
        prompt.enableGesturesOnPrompt(gestureEnabler: false)
        
        
        if category == nil {
            prompt.setPromptHeader(header: "Oops".uppercased())
            prompt.setPromptHeaderTxtSize(headerTxtSize: 25)
            
            prompt.setPromptContentText(contentTxt: "You have to choose a category first!".uppercased())
            prompt.setPromptContentTxtSize(contentTxtSize: 18)
            
            prompt.setMainButtonText(buttonTitle: "Ok".uppercased())
            prompt.setMainButtonColor(colorForButton: .white)
            prompt.setMainButtonBackgroundColor(colorForBackground: CustomColor.customGreen)
            prompt.setMainButtonAction {
                self.prompt.dismissPrompt()
                self.didCancelLoading()
            }
        } else {
            prompt.setPromptHeader(header: "Hol' up".uppercased())
            prompt.setPromptHeaderTxtSize(headerTxtSize: 25)
            
            prompt.setPromptContentText(contentTxt: "We can't find any new trivia. Would you like to play the same ones again?".uppercased())
            prompt.setPromptContentTxtSize(contentTxtSize: 18)
            
            prompt.enableDoubleButtonsOnPrompt()
            
            prompt.setMainButtonText(buttonTitle: "Sure!".uppercased())
            prompt.setMainButtonColor(colorForButton: .white)
            prompt.setMainButtonBackgroundColor(colorForBackground: CustomColor.customGreen)
            prompt.setMainButtonAction {
    
            }
            
            prompt.setSecondButtonText(secondButtonTitle: "Nah".uppercased())
            prompt.setSecondButtonColor(colorForSecondButton: UIColor.white)
            prompt.setSecondButtonAction {
                self.prompt.dismissPrompt()
                self.didCancelLoading()
            }
        }
        
        self.view.addSubview(prompt)
    }
    
    private func leaveViewController() {
        playLabel.isHidden = false
        playButton.startFinishAnimation(0 , completion: {
            let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
            gameVC.transitioningDelegate = self
            self.present(gameVC, animated: true, completion: {
                self.view.isUserInteractionEnabled = true
            })
        })
    }
    
    func didStartLoading() {
        self.view.isUserInteractionEnabled = false
        playLabel.isHidden = true
        playButton.startLoadingAnimation()
    }
    
    func didCancelLoading() {
        self.view.isUserInteractionEnabled = true
        playLabel.isHidden = false
        playButton.returnToOriginalState()
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension LandingViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fadeInAnimator = TKFadeInAnimator()
        return fadeInAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fadeInAnimator = TKFadeInAnimator()
        return fadeInAnimator
    }
}
