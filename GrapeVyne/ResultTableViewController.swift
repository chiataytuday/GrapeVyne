//
//  ResultTableViewController.swift
//  StoryApp
//
//  Created by Umair Sharif on 2/24/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import SafariServices

// Mark: Global properties
// Images
private let trueImage = #imageLiteral(resourceName: "result_true")
private let falseImage = #imageLiteral(resourceName: "result_false")
// Color config
private let viewBackgroundColor = UIColor.black
private let tableViewBackgroundColor = UIColor.clear
private let correctCounterLabelTextColor = CustomColor.customGreen
private let incorrectCounterLabelTextColor = CustomColor.customDarkRed
private let cellBackgroundColor = CustomColor.customPurple
private let storyLabelTextColor = UIColor.white
private let resultTextColor = UIColor.white.withAlphaComponent(0.7)

class ResultTableViewCell: UITableViewCell {
    var storyURLasString = ""
    var parentVC : UIViewController?
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var correctAnsLabel: UILabel!
    @IBOutlet weak var userAnsLabel: UILabel!
    
    @IBAction func linkButton(_ sender: UIButton) {
        let svc = SFSafariViewController(url: URL(string: storyURLasString)!)
        svc.preferredBarTintColor = .black
        parentVC?.present(svc, animated: true, completion: nil)
    }
    
}

class ResultTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultCounterLabel: UILabel!
    let cellSpacingHeight : CGFloat = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
        view.backgroundColor = viewBackgroundColor
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.layer.cornerRadius = cardCornerRadius
        
        //resultCounterLabel.text = "\(storyRepo.arrayOfCorrectStories.count) CORRECT\n\(storyRepo.arrayOfIncorrectStories.count) INCORRECT"
        let resultCounterString = "\(storyRepo.arrayOfCorrectStories.count) CORRECT\n\(storyRepo.arrayOfIncorrectStories.count) INCORRECT"
        let correctCounterString = "\(storyRepo.arrayOfCorrectStories.count) CORRECT\n"
        let correctRange = NSRange(location: 0, length: correctCounterString.characters.count)
        
        let incorrectCounterString = "\(storyRepo.arrayOfIncorrectStories.count) INCORRECT"
        let incorrectRange = NSRange(location: correctCounterString.characters.count, length: incorrectCounterString.characters.count)
        
        
        var myMutableString = NSMutableAttributedString()
        
        myMutableString = NSMutableAttributedString(string: resultCounterString, attributes: nil)
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: correctCounterLabelTextColor, range: correctRange)
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: incorrectCounterLabelTextColor, range: incorrectRange)
        resultCounterLabel.attributedText = myMutableString
        resultCounterLabel.backgroundColor = CustomColor.customPurple
        resultCounterLabel.layer.cornerRadius = cardCornerRadius
        resultCounterLabel.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        storyRepo.arrayOfSwipedStories = []
        storyRepo.arrayOfCorrectStories = []
        storyRepo.arrayOfIncorrectStories = []
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return storyRepo.arrayOfSwipedStories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ResultTableViewCell
        cell.selectionStyle = .none
        cell.parentVC = self
        cell.storyLabel.textColor =  storyLabelTextColor
        cell.correctAnsLabel.textColor = resultTextColor
        cell.userAnsLabel.textColor = resultTextColor
        cell.backgroundColor = cellBackgroundColor
        cell.layer.cornerRadius = cardCornerRadius

        let story = storyRepo.arrayOfSwipedStories[indexPath.section]
        cell.storyLabel.text = story.title
        cell.storyURLasString = story.url!
        if storyRepo.arrayOfCorrectStories.contains(where: {$0.title == story.title}) {
            //user was correct, now just match result images
            if story.fact {
                cell.correctAnsLabel.addImage(image: trueImage)
                cell.userAnsLabel.addImage(image: trueImage)
            } else {
                cell.correctAnsLabel.addImage(image: falseImage)
                cell.userAnsLabel.addImage(image: falseImage)
            }
        } else if storyRepo.arrayOfIncorrectStories.contains(where: {$0.title == story.title}) {
            //user was incorrect, now opposite images
            if story.fact {
                cell.correctAnsLabel.addImage(image: trueImage)
                cell.userAnsLabel.addImage(image: falseImage)
            } else {
                cell.correctAnsLabel.addImage(image: falseImage)
                cell.userAnsLabel.addImage(image: trueImage)
            }
        }
        return cell
    }
    
}
extension UILabel {
    func addImage(image: UIImage) {
        let attachment = NSTextAttachment()
        attachment.image = image

        attachment.bounds = CGRect(x: 8.0, y: -5.0, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
        let attachmentString = NSAttributedString(attachment: attachment)
        let myString = NSMutableAttributedString(string: self.text!)
        myString.append(attachmentString)
        
        self.attributedText = myString
    }
}
