//
//  ResultTableViewController.swift
//  StoryApp
//
//  Created by Umair Sharif on 2/24/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import SafariServices

private let customLightGray = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1.0)

class ResultTableViewCell: UITableViewCell {
    var storyURLasString = ""
    var parentVC : UIViewController?
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var correctAnsLabel: UILabel!
    @IBOutlet weak var userAnsLabel: UILabel!
    
    @IBAction func linkButton(_ sender: UIButton) {
        let svc = SFSafariViewController(url: URL(string: storyURLasString)!)
        parentVC?.present(svc, animated: true, completion: nil)
    }
    
}

class ResultTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.textAlignment = .center
        if section == 0 {
            headerLabel.text = "Correct"
        } else if section == 1 {
            headerLabel.text = "Incorrect"
        }
        return headerLabel
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var str = ""
        if section == 0 {
            str = "Correct"
        } else if section == 1 {
            str = "Incorrect"
        }
        return str
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        if section == 0 {
            numRows = storyRepo.arrayOfCorrectStories.count
        } else if section == 1 {
            numRows = storyRepo.arrayOfIncorrectStories.count
        }
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ResultTableViewCell
        cell.selectionStyle = .none
        cell.parentVC = self
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = customLightGray
        }
        
        if indexPath.section == 0 {
            configureCell(cell: cell, story: storyRepo.arrayOfCorrectStories[indexPath.row], userCorrect: true)
        } else if indexPath.section == 1 {
            configureCell(cell: cell, story: storyRepo.arrayOfIncorrectStories[indexPath.row], userCorrect: false)
        }
        return cell
    }
    
    private func configureCell(cell: ResultTableViewCell, story: Story, userCorrect: Bool) {
        cell.storyLabel.text = story.title
        cell.correctAnsLabel.text = "Answer: \(story.fact)"
        if userCorrect {
            cell.userAnsLabel.text = "You said: \(String(story.fact))"
        } else {
            cell.userAnsLabel.text = "You said: \(String(!story.fact))"
        }
        cell.storyURLasString = story.urlString
    }

}
