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
private let tableViewBackgroundColor = CustomColor.customPurple
private let cellBackgroundColor = UIColor.white.withAlphaComponent(0.3)
private let storyLabelTextColor = UIColor.white
private let resultTextColor = UIColor.white.withAlphaComponent(0.7)

class ResultTableViewCell: UITableViewCell {
    var storyURLasString = ""
    var parentVC : UIViewController?
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var correctAnsLabel: UILabel!
    @IBOutlet weak var userAnsLabel: UILabel!
    @IBOutlet weak var correctAnsImage: UIImageView!
    @IBOutlet weak var userAnsImage: UIImageView!
    
    @IBAction func linkButton(_ sender: UIButton) {
        let svc = SFSafariViewController(url: URL(string: storyURLasString)!)
        svc.preferredBarTintColor = .black
        parentVC?.present(svc, animated: true, completion: nil)
    }
    
}

class ResultTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.clear
        tableView.backgroundColor = tableViewBackgroundColor
        tableView.layer.cornerRadius = cardCornerRadius
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storyRepo.arrayOfSwipedStories.count
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
        
        let story = storyRepo.arrayOfSwipedStories[indexPath.row]
        cell.storyLabel.text = story.title
        cell.storyURLasString = story.urlString
        if storyRepo.arrayOfCorrectStories.contains(where: {$0.title == story.title}) {
            if story.fact {
                cell.correctAnsImage.image = trueImage
                cell.userAnsImage.image = trueImage
            } else {
                cell.correctAnsImage.image = falseImage
                cell.userAnsImage.image = falseImage
            }
        } else if storyRepo.arrayOfIncorrectStories.contains(where: {$0.title == story.title}) {
            if story.fact {
                cell.correctAnsImage.image = trueImage
                cell.userAnsImage.image = falseImage
            } else {
                cell.correctAnsImage.image = falseImage
                cell.userAnsImage.image = trueImage
            }
        }
        return cell
    }
}
