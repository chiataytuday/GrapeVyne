//
//  LandingViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import Async
import PickerView

class LandingViewController: UIViewController {
    let landingCornerRadius: CGFloat = 12.5
    let numberOfStoriesOpenTrivia = 20
    var selectedRow: Int?
    var playLabel: UILabel!
    let playButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
        
        playButton.backgroundColor = CustomColor.customPurple
//        playButton.spinnerColor = CustomColor.customGreen
//        playButton.normalCornerRadius = 25
        
        playLabel = UILabel(frame: CGRect(x: 0, y: 0, width: playButton.bounds.size.width, height: playButton.bounds.size.height))
        playLabel.center = CGPoint(x: playButton.bounds.size.width / 2.0, y: playButton.bounds.size.height / 2.0)
        playLabel.textAlignment = .center
        playLabel.attributedText = NSAttributedString(string: "Play".uppercased(), attributes: [NSAttributedString.Key.font : UIFont(name: "Gotham-Bold", size: 40.0)!])
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
        
        let refreshDBAction = UIAlertAction(title: "Refresh Database", style: .destructive, handler: { _ in
            let managedObject = CoreDataManager.fetchModel(entity: "CDStory")
            for object in managedObject {
                CoreDataManager.deleteObjectBy(id: object.objectID)
            }
            self.dismiss(animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(viewTutorialAction)
        optionMenu.addAction(viewCreditsAction)
        optionMenu.addAction(refreshDBAction)
        optionMenu.addAction(cancelAction)
        
        optionMenu.view.tintColor = CustomColor.customPurple
        present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        didStartLoading()
        var arrayToPass = [Story]()
  
        Async.userInitiated({
            var randBool = self.randomBool()
            while arrayToPass.count < 30 {
                while !storyRepo.arrayOfStories.contains(where: {$0.fact == randBool}) {
                    storyRepo.arrayOfStories.append(contentsOf: snopesScrapeNetwork.getStories())
                }
                for story in storyRepo.arrayOfStories {
                    if story.fact == randBool {
                        arrayToPass.append(story)
                        if let index = storyRepo.arrayOfStories.firstIndex(where: {$0.id == story.id}) {
                            storyRepo.arrayOfStories.remove(at: index)
                        }
                        randBool = self.randomBool()
                        break
                    }
                }
            }
        }).main({
            self.leaveViewController(with: arrayToPass)
        })
    }
    
    private func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
    
    private func leaveViewController(with: [Story]) {
        playLabel.isHidden = false
//        playButton.startFinishAnimation(0 , completion: {
//            let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
//            gameVC.transitioningDelegate = self
//            gameVC.gameSetArray = with
//            self.present(gameVC, animated: true, completion: {
//                self.view.isUserInteractionEnabled = true
//            })
//        })
    }
    
    func didStartLoading() {
        self.view.isUserInteractionEnabled = false
        playLabel.isHidden = true
        //playButton.startLoadingAnimation()
    }
    
    func didCancelLoading() {
        self.view.isUserInteractionEnabled = true
        playLabel.isHidden = false
        //playButton.returnToOriginalState()
    }
}
