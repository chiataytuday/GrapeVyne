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
    var pickerCategories = [Category]()
    var prompt = SwiftPromptsView()
    var playLabel: UILabel!
    @IBOutlet weak var segmentControl: DGRunkeeperSwitch!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var playButton: TKTransitionSubmitButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
        
        segmentControl.setSelectedIndex(0, animated: false)
        segmentControl.titles = ["Open Trivia DB".uppercased(), "Snopes".uppercased()]
        segmentControl.backgroundColor = .darkGray
        segmentControl.selectedBackgroundColor = CustomColor.customPurple
        segmentControl.titleColor = .lightGray
        segmentControl.selectedTitleColor = .white
        segmentControl.titleFont = UIFont(name: "Gotham-Bold", size: 10.0)
        
        pickerCategories = categoryRepo.arrayOfOpenTriviaDBCategories
        let attstring = NSAttributedString(string: "Choose category".uppercased(), attributes: [NSFontAttributeName : UIFont(name: "Gotham-Bold", size: 22.0)!])
        categoryButton.setAttributedTitle(attstring, for: .normal)
        categoryButton.titleLabel?.textAlignment = .center
        categoryButton.titleLabel?.textColor = .lightGray
        categoryButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectedRow = nil
        
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
    
    @IBAction func segmentControl(_ sender: DGRunkeeperSwitch) {
        switch sender.selectedIndex {
        case 0:
            pickerCategories = categoryRepo.arrayOfOpenTriviaDBCategories
        case 1:
            pickerCategories = categoryRepo.arrayOfSnopesCategories
        default: break
        }
        let attstring = NSAttributedString(string: "Choose category".uppercased(), attributes: [NSFontAttributeName : UIFont(name: "Gotham-Bold", size: 18.0)!])
        categoryButton.setAttributedTitle(attstring, for: .normal)
        categoryButton.titleLabel?.textAlignment = .center
        categoryButton.titleLabel?.textColor = .lightGray
        categoryButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectedRow = nil
    }
    
    @IBAction func categoryButton(_ sender: UIButton) {
        let inputView = Bundle.main.loadNibNamed("CategoryPickerView", owner: self, options: nil)?[0] as! CategoryPickerView
        inputView.pickerView.dataSource = self
        inputView.pickerView.delegate = self
        
        var blurEffectView = UIVisualEffectView()
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = cardCornerRadius
        blurEffectView.layer.masksToBounds = true
        blurEffectView.frame = inputView.pickerView.bounds
        inputView.pickerView.addSubview(blurEffectView)
        inputView.pickerView.backgroundColor = .clear
        
        inputView.doneButton.setTitleColor(.white, for: .normal)
        inputView.doneButton.backgroundColor = CustomColor.customGreen
        inputView.doneButton.layer.cornerRadius = 16
        inputView.doneButton.layer.masksToBounds = true
        inputView.doneButton.titleLabel!.font = UIFont(name: "Gotham-Bold", size: 20)
        inputView.doneButton.setTitle("Done".uppercased(), for: .normal)
        
        inputView.pickerView.layer.cornerRadius = cardCornerRadius
        inputView.pickerView.layer.masksToBounds = true
        inputView.doneButtonAction = {
            self.selectedRow = inputView.pickerView.currentSelectedRow
            let a = self.pickerCategories[self.selectedRow!].title
            let attstring = NSAttributedString(string: a.uppercased(), attributes: [NSFontAttributeName : UIFont(name: "Gotham-Bold", size: 22.0)!])
            self.categoryButton.setAttributedTitle(attstring, for: .normal)
            self.categoryButton.titleLabel?.textColor = CustomColor.customGreen
            inputView.removeFromSuperview()
        }
        inputView.pickerView.selectionStyle = .overlay
        
        let overLayView = UIView()
        overLayView.backgroundColor = CustomColor.customPurple.withAlphaComponent(0.3)
        inputView.pickerView.selectionOverlay = overLayView
        
        if selectedRow == nil {
            inputView.pickerView.selectRow(0, animated: false)
        } else {
            inputView.pickerView.currentSelectedRow = selectedRow
        }
        view.addSubview(inputView)
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        view.isUserInteractionEnabled = false
        didStartLoading()
        storyRepo.arrayOfStories = [Story]()
  
        Async.userInitiated({
            self.prepare(completion: {(bool, cat) in
                Async.main({
                    if bool {
                        self.leaveViewController()
                    } else {
                        if cat == nil {
                            self.presentCustomAlertViewControllerFor(category: nil)
                        }
                        if let c = cat {
                           self.presentCustomAlertViewControllerFor(category: c)
                        }
                    }
                })
            })
        })
    }
    
    private func prepare(completion: @escaping (Bool, Category?)->Void) {
        var chosenCategory: Category
        if selectedRow == nil {
            completion(false, nil)
        } else {
            switch self.segmentControl.selectedIndex {
            case 0: // Open trivia
                chosenCategory = categoryRepo.arrayOfOpenTriviaDBCategories[self.selectedRow!]
                if chosenCategory.title == "Random" {
                    openTriviaDBNetwork.getRandomStories(amount: self.numberOfStoriesOpenTrivia, returnExhausted: false, completion: { arrayOfStories in
                        if arrayOfStories != nil {
                            storyRepo.arrayOfStories = arrayOfStories!
                            completion(true, nil)
                        } else {
                            completion(false, chosenCategory)
                        }
                    })
                } else {
                    openTriviaDBNetwork.getStoriesFor(categoryId: chosenCategory.id, amount: self.numberOfStoriesOpenTrivia, returnExhausted: false, completion: {arrayOfStories in
                        if arrayOfStories != nil {
                            storyRepo.arrayOfStories = arrayOfStories!
                            completion(true, nil)
                        } else {
                            completion(false, chosenCategory)
                        }
                    })
                }
                
            case 1: // Snopes
                chosenCategory = categoryRepo.arrayOfSnopesCategories[self.selectedRow!]
                if let arrayOfStories = chosenCategory.stories { // Stories in memory
                    storyRepo.arrayOfStories = arrayOfStories
                    completion(true, nil)
                } else { // No stories in memory
                    snopesScrapeNetwork.getStoriesFor(category: chosenCategory, completion: { arrayOfStories in
                        categoryRepo.arrayOfSnopesCategories[self.selectedRow!].stories = arrayOfStories
                        storyRepo.arrayOfStories = arrayOfStories
                        completion(true, nil)
                    })
                }
            default: break
            }
        }
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
                self.prompt.dismissPrompt()
                self.didStartLoading()
                Async.userInitiated({
                    openTriviaDBNetwork.getStoriesFor(categoryId: category!.id, amount: self.numberOfStoriesOpenTrivia, returnExhausted: true, completion: {arrayOfStories in
                        storyRepo.arrayOfStories = arrayOfStories!
                        self.leaveViewController()
                    })
                })
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

// MARK: PickerViewDataSource

extension LandingViewController: PickerViewDataSource {
    
    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        return pickerCategories.count
    }
    
    func pickerView(_ pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        return pickerCategories[row].title
    }
}

// MARK: UIPickerViewDelegate

extension LandingViewController: PickerViewDelegate {
    
    func pickerViewHeightForRows( _ pickerView: PickerView) -> CGFloat {
        return 25
    }
    
    func pickerView(_ pickerView: PickerView, didSelectRow row: Int, index: Int) {
        selectedRow = row
    }
    
    func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        label.text = label.text?.uppercased()
        let attTitle = NSAttributedString(string: label.text!, attributes: [
            NSFontAttributeName: UIFont(name: "Gotham-Bold", size: 22.0)!,
            NSForegroundColorAttributeName: UIColor.white])
        label.attributedText = attTitle
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
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
