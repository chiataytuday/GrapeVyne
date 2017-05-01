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

class LandingViewController: UIViewController {
    let landingCornerRadius: CGFloat = 12.5
    let numberOfStoriesOpenTrivia = 20
    var selectedRow = 0
    var pickerCategories = [Category]()
    var prompt = SwiftPromptsView()
    var playLabel: UILabel!
    @IBOutlet weak var segmentControl: DGRunkeeperSwitch!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var playButton: TKTransitionSubmitButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        modalTransitionStyle = appModalTransitionStyle
        picker.backgroundColor = UIColor.clear
        playButton.backgroundColor = CustomColor.customPurple
        playButton.spinnerColor = CustomColor.customGreen
        playButton.normalCornerRadius = 25
        
        playLabel = UILabel(frame: CGRect(x: 0, y: 0, width: playButton.bounds.size.width, height: playButton.bounds.size.height))
        playLabel.center = CGPoint(x: playButton.bounds.size.width / 2.0, y: playButton.bounds.size.height / 2.0)
        playLabel.textAlignment = .center
        playLabel.attributedText = NSAttributedString(string: "Play".uppercased(), attributes: [NSFontAttributeName : UIFont(name: "Gotham-Bold", size: 40.0)!])
        playLabel.textColor = .white
        playButton.addSubview(playLabel)
        
        segmentControl.setSelectedIndex(0, animated: false)
        pickerCategories = categoryRepo.arrayOfOpenTriviaDBCategories
        segmentControl.titles = ["Open Trivia DB".uppercased(), "Snopes".uppercased()]
        segmentControl.backgroundColor = .darkGray
        segmentControl.selectedBackgroundColor = CustomColor.customPurple
        segmentControl.titleColor = .lightGray
        segmentControl.selectedTitleColor = .white
        segmentControl.titleFont = UIFont(name: "Gotham-Bold", size: 10.0)

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
    @IBAction func segmentControl(_ sender: DGRunkeeperSwitch) {
        switch sender.selectedIndex {
        case 0:
            pickerCategories = categoryRepo.arrayOfOpenTriviaDBCategories
        case 1:
            pickerCategories = categoryRepo.arrayOfSnopesCategories
        default: break
        }
        picker.reloadAllComponents()
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        didStartLoading()
        storyRepo.arrayOfStories = [Story]()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var chosenCategory: Category
            switch self.segmentControl.selectedIndex {
            case 0: // Open trivia
                chosenCategory = categoryRepo.arrayOfOpenTriviaDBCategories[self.selectedRow]
                if chosenCategory.title == "Random" {
                    openTriviaDBNetwork.getRandomStories(amount: self.numberOfStoriesOpenTrivia, returnExhausted: false, completion: { arrayOfStories in
                        if arrayOfStories != nil {
                            storyRepo.arrayOfStories = arrayOfStories!
                            self.leaveViewController()
                        } else {
                            self.presentCustomAlertViewController(category: chosenCategory)
                        }
                    })
                } else {
                    openTriviaDBNetwork.getStoriesFor(categoryId: chosenCategory.id, amount: self.numberOfStoriesOpenTrivia, returnExhausted: false, completion: {arrayOfStories in
                        if arrayOfStories != nil {
                            storyRepo.arrayOfStories = arrayOfStories!
                            self.leaveViewController()
                        } else {
                            self.presentCustomAlertViewController(category: chosenCategory)
                        }
                    })
                }
                
            case 1: // Snopes
                chosenCategory = categoryRepo.arrayOfSnopesCategories[self.selectedRow]
                if let arrayOfStories = chosenCategory.stories { // Stories in memory
                    storyRepo.arrayOfStories = arrayOfStories
                    self.leaveViewController()
                } else { // No stories in memory
                    snopesScrapeNetwork.getStoriesFor(category: chosenCategory, completion: { arrayOfStories in
                        categoryRepo.arrayOfSnopesCategories[self.selectedRow].stories = arrayOfStories
                        storyRepo.arrayOfStories = arrayOfStories
                        self.leaveViewController()
                    })
                }
            default: break
            }
        }
    }
    
    private func presentCustomAlertViewController(category: Category) {
        self.view.isUserInteractionEnabled = true
        prompt = SwiftPromptsView(frame: self.view.bounds)
        
        prompt.setColorWithTransparency(color: .clear)
        
        prompt.setPromptHeight(height: 0.35 * (view.frame.height))
        prompt.setPromptWidth(width: 0.75 * (view.frame.width))
        
        prompt.setPromptHeader(header: "Hol' up".uppercased())
        prompt.setPromptHeaderTxtSize(headerTxtSize: 25)
        
        prompt.setPromptContentText(contentTxt: "We can't find any new trivia. Would you like to play the same ones again?".uppercased())
        prompt.setPromptContentTxtSize(contentTxtSize: 18)
        
        prompt.setPromptButtonDividerVisibility(dividerVisibility: false)
        prompt.setPromptTopLineVisibility(topLineVisibility: false)
        prompt.setPromptBackgroundColor(backgroundColor: CustomColor.customPurple)
        
        prompt.enableDoubleButtonsOnPrompt()
        
        prompt.setMainButtonText(buttonTitle: "Sure!".uppercased())
        prompt.setMainButtonColor(colorForButton: .white)
        prompt.setMainButtonBackgroundColor(colorForBackground: CustomColor.customGreen)
        prompt.setMainButtonAction {
            self.prompt.dismissPrompt()
            self.didStartLoading()
            DispatchQueue.global(qos: .userInitiated).async {
                openTriviaDBNetwork.getStoriesFor(categoryId: category.id, amount: self.numberOfStoriesOpenTrivia, returnExhausted: true, completion: {arrayOfStories in
                    storyRepo.arrayOfStories = arrayOfStories!
                    self.leaveViewController()
                })
            }
        }
        
        prompt.setSecondButtonText(secondButtonTitle: "Nah".uppercased())
        prompt.setSecondButtonColor(colorForSecondButton: UIColor.white)
        prompt.setSecondButtonAction {
            self.prompt.dismissPrompt()
            self.didCancelLoading()
        }
        
        prompt.enableGesturesOnPrompt(gestureEnabler: false)
        
        self.view.addSubview(prompt)
    }
    
    private func leaveViewController() {
        self.view.isUserInteractionEnabled = true
        playLabel.isHidden = false
        playButton.startFinishAnimation(0 , completion: {
            let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
            gameVC.transitioningDelegate = self
            self.present(gameVC, animated: true, completion: nil)
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

// MARK: UIPickerViewDataSource

extension LandingViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  // if no label there yet
            pickerLabel = UILabel()
        }
        let title = pickerCategories[row].title.uppercased()
        let attTitle = NSAttributedString(string: title, attributes: [
            NSFontAttributeName: UIFont(name: "Gotham-Bold", size: 22.0)!,
            NSForegroundColorAttributeName: UIColor.white])
        pickerLabel?.attributedText = attTitle
        pickerLabel?.textAlignment = .center
        pickerLabel?.backgroundColor = CustomColor.customPurple
        pickerLabel?.layer.cornerRadius = landingCornerRadius
        pickerLabel?.layer.masksToBounds = true
        pickerLabel?.adjustsFontSizeToFitWidth = true
        return pickerLabel!
    }
}

// MARK: UIPickerViewDelegate

extension LandingViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
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

