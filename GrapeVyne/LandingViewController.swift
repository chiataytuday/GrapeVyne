//
//  LandingViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import JSSAlertView

class LandingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIViewControllerTransitioningDelegate {
    var activityIndicator: ActivityIndicatorView!
    let landingCornerRadius: CGFloat = 8.0
    let segmentedControlLabelAttrbiutesDict = [NSFontAttributeName: UIFont(name: "Gotham-Bold", size: 14.0)!]
    let numberOfStoriesOpenTrivia = 20
    var selectedRow = 0
    var pickerCategories = [Category]()
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var segmentControl: SMSegmentView!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        modalTransitionStyle = appModalTransitionStyle
        picker.backgroundColor = UIColor.clear
        setupSegmentControl()
        playButton.backgroundColor = UIColor.black
        activityIndicator = ActivityIndicatorView(text: "Loading")
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
        self.view.addSubview(activityIndicator)
        activityIndicator.show()
        self.view.isUserInteractionEnabled = false
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
                            self.leaveViewController(sender: sender)
                        } else {
                            self.presentCustomAlertViewController(category: chosenCategory, sender: sender)
                        }
                    })
                } else {
                    openTriviaDBNetwork.getStoriesFor(categoryId: chosenCategory.id, amount: self.numberOfStoriesOpenTrivia, returnExhausted: false, completion: {arrayOfStories in
                        if arrayOfStories != nil {
                            storyRepo.arrayOfStories = arrayOfStories!
                            self.leaveViewController(sender: sender)
                        } else {
                            self.presentCustomAlertViewController(category: chosenCategory, sender: sender)
                        }
                    })
                }
                
            case 1: // Snopes
                chosenCategory = categoryRepo.arrayOfSnopesCategories[self.selectedRow]
                if let arrayOfStories = chosenCategory.stories { // Stories in memory
                    storyRepo.arrayOfStories = arrayOfStories
                    self.leaveViewController(sender: sender)
                } else { // No stories in memory
                    snopesScrapeNetwork.getStoriesFor(category: chosenCategory, completion: { arrayOfStories in
                        categoryRepo.arrayOfSnopesCategories[self.selectedRow].stories = arrayOfStories
                        storyRepo.arrayOfStories = arrayOfStories
                        self.leaveViewController(sender: sender)
                    })
                }
            default: break
            }
            DispatchQueue.main.async {
                self.activityIndicator.hide()
            }
        }
    }
    
    private func presentCustomAlertViewController(category: Category, sender: UIButton) {
        let alertview = JSSAlertView().show(self,
                                            title: "Hol' up".uppercased(),
                                            text: "We can't find any new trivia. Would you like to play the same ones again?".uppercased(),
                                            buttonText: "Sure!".uppercased(),
                                            cancelButtonText: "Nah".uppercased(),
                                            color: CustomColor.customPurple)
        alertview.addAction({_ in
            openTriviaDBNetwork.getStoriesFor(categoryId: category.id, amount: self.numberOfStoriesOpenTrivia, returnExhausted: true, completion: {arrayOfStories in
                storyRepo.arrayOfStories = arrayOfStories!
                self.leaveViewController(sender: sender)
            })
        })
        alertview.addCancelAction({_ in
            self.activityIndicator.hide()
            self.view.isUserInteractionEnabled = true
        })
        alertview.setTitleFont("Gotham-Bold")
        alertview.setTextFont("Gotham-Bold")
        alertview.setButtonFont("Gotham-Bold")
        alertview.setTextTheme(.light)
    }
    
    private func leaveViewController(sender: UIButton) {
        self.performSegue(withIdentifier: "playButton", sender: sender)
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.hide()
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }

}
