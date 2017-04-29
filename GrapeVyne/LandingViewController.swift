//
//  LandingViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import JSSAlertView
import TKSubmitTransitionSwift3

class LandingViewController: UIViewController {
    let landingCornerRadius: CGFloat = 8.0
    let segmentedControlLabelAttrbiutesDict = [NSFontAttributeName: UIFont(name: "Gotham-Bold", size: 14.0)!]
    let numberOfStoriesOpenTrivia = 20
    var selectedRow = 0
    var pickerCategories = [Category]()
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var segmentControl: SMSegmentView!
    @IBOutlet weak var playButton: TKTransitionSubmitButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        modalTransitionStyle = appModalTransitionStyle
        picker.backgroundColor = UIColor.clear
        setupSegmentControl()
        playButton.backgroundColor = CustomColor.customPurple
        playButton.spinnerColor = CustomColor.customGreen
        playButton.normalCornerRadius = 25
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
    
    @IBAction func segmentControl(_ sender: SMSegmentView) {
        switch sender.selectedSegmentIndex {
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
            switch self.segmentControl.selectedSegmentIndex {
            case 0: // Open trivia
                chosenCategory = categoryRepo.arrayOfOpenTriviaDBCategories[self.selectedRow]
                if chosenCategory.title == "Random" {
                    openTriviaDBNetwork.getRandomStories(amount: self.numberOfStoriesOpenTrivia, returnExhausted: false, completion: { arrayOfStories in
                        if arrayOfStories != nil {
                            storyRepo.arrayOfStories = arrayOfStories!
                            self.leaveViewController()
                        } else {
                            self.presentCustomAlertViewController(category: chosenCategory, sender: sender)
                        }
                    })
                } else {
                    openTriviaDBNetwork.getStoriesFor(categoryId: chosenCategory.id, amount: self.numberOfStoriesOpenTrivia, returnExhausted: false, completion: {arrayOfStories in
                        if arrayOfStories != nil {
                            storyRepo.arrayOfStories = arrayOfStories!
                            self.leaveViewController()
                        } else {
                            self.presentCustomAlertViewController(category: chosenCategory, sender: sender)
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
    
    private func presentCustomAlertViewController(category: Category, sender: UIButton) {
        didCancelLoading()
        let alertview = JSSAlertView().show(self,
                                            title: "Hol' up".uppercased(),
                                            text: "We can't find any new trivia. Would you like to play the same ones again?".uppercased(),
                                            buttonText: "Sure!".uppercased(),
                                            cancelButtonText: "Nah".uppercased(),
                                            color: CustomColor.customPurple)
        alertview.addAction({_ in
            self.didStartLoading()
            DispatchQueue.global(qos: .userInitiated).async {
                openTriviaDBNetwork.getStoriesFor(categoryId: category.id, amount: self.numberOfStoriesOpenTrivia, returnExhausted: true, completion: {arrayOfStories in
                    storyRepo.arrayOfStories = arrayOfStories!
                    self.leaveViewController()
                })
            }
        })
        alertview.addCancelAction({_ in
            self.didCancelLoading()
        })
        alertview.setTitleFont("Gotham-Bold")
        alertview.setTextFont("Gotham-Bold")
        alertview.setButtonFont("Gotham-Bold")
        alertview.setTextTheme(.light)
    }
    
    private func leaveViewController() {
        self.view.isUserInteractionEnabled = true
        playButton.startFinishAnimation(0 , completion: {
            let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
            gameVC.transitioningDelegate = self
            self.present(gameVC, animated: true, completion: nil)
        })
    }
    
    private func didStartLoading() {
        self.view.isUserInteractionEnabled = false
        playButton.startLoadingAnimation()
    }
    
    private func didCancelLoading() {
        self.view.isUserInteractionEnabled = true
        playButton.returnToOriginalState()
    }
    
    func setupSegmentControl() {
        let appearence = SMSegmentAppearance()
        appearence.titleOnSelectionColour = UIColor.white
        appearence.titleOffSelectionColour = CustomColor.customLightGray
        appearence.segmentOnSelectionColour = CustomColor.customPurple
        appearence.segmentOffSelectionColour = UIColor.darkGray
        segmentControl.segmentAppearance = appearence
        segmentControl.backgroundColor = UIColor.clear
        segmentControl.layer.cornerRadius = landingCornerRadius
        segmentControl.layer.masksToBounds = true
        
        segmentControl.addSegmentWithAttributedTitle(NSMutableAttributedString(string: "OPEN TRIVIA DB", attributes: segmentedControlLabelAttrbiutesDict),
                                                     onSelectionImage: nil,
                                                     offSelectionImage: nil)
        segmentControl.addSegmentWithAttributedTitle(NSMutableAttributedString(string: "SNOPES", attributes: segmentedControlLabelAttrbiutesDict),
                                                     onSelectionImage: nil,
                                                     offSelectionImage: nil)
        segmentControl.selectedSegmentIndex = 0
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
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fadeInAnimator = TKFadeInAnimator()
        return fadeInAnimator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

}
