//
//  LandingViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var selectedRow = 0
    @IBOutlet weak var picker: UIPickerView!
    let activityIndicator = ActivityIndicatorView(text: "Loading")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        modalTransitionStyle = appModalTransitionStyle
        picker.backgroundColor = UIColor.clear
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
        storyRepo.arrayOfStories = [Story]()
        self.view.addSubview(activityIndicator)
        activityIndicator.show()
        let chosenCategory = categoryRepo.arrayOfCategories[selectedRow]
        if let arrayOfStories = chosenCategory.stories { // Stories in memory
            storyRepo.arrayOfStories = arrayOfStories
            self.performSegue(withIdentifier: "playButton", sender: sender)
            self.activityIndicator.hide()
        } else { // No stories in memory
            network.getStoriesFor(category: chosenCategory, completion: { array in
                categoryRepo.arrayOfCategories[self.selectedRow].stories = array
                storyRepo.arrayOfStories = array
                for story in array {
                    CoreDataManager.addStoryToCategory(category: chosenCategory, story: story)
                }
                self.performSegue(withIdentifier: "playButton", sender: sender)
                self.activityIndicator.hide()
            })
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryRepo.arrayOfCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  // if no label there yet
            pickerLabel = UILabel()
        }
        let title = categoryRepo.arrayOfCategories[row].title.uppercased()
        let attTitle = NSAttributedString(string: title, attributes: [
            NSFontAttributeName: UIFont(name: "Gotham-Bold", size: 22.0)!,
            NSForegroundColorAttributeName: UIColor.white])
        pickerLabel?.attributedText = attTitle
        pickerLabel?.textAlignment = .center
        pickerLabel?.backgroundColor = CustomColor.customPurple
        pickerLabel?.layer.cornerRadius = 8.0
        pickerLabel?.layer.masksToBounds = true
        pickerLabel?.adjustsFontSizeToFitWidth = true
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}
