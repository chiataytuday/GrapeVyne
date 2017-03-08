//
//  ResultTableViewController.swift
//  StoryApp
//
//  Created by Umair Sharif on 2/24/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import SafariServices

private let correctUnderlayImage = #imageLiteral(resourceName: "correctBanner")
private let incorrectUnderlayImage = #imageLiteral(resourceName: "incorrectBanner")

class ResultTableViewCell: UITableViewCell {
    var storyURLasString = ""
    var parentVC : UIViewController?
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var correctAnsLabel: UILabel!
    @IBOutlet weak var userAnsLabel: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    
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
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "splash"))
        tableView.separatorColor = UIColor.black
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
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
        
        if storyRepo.arrayOfCorrectStories.contains(where: {$0.title == storyRepo.arrayOfSwipedStories[indexPath.row].title}) {
            //correct answer cell
            configureCell(cell: cell, story: storyRepo.arrayOfSwipedStories[indexPath.row], userCorrect: true)
        } else if storyRepo.arrayOfIncorrectStories.contains(where: {$0.title == storyRepo.arrayOfSwipedStories[indexPath.row].title}) {
            //incorrect answer cell
            configureCell(cell: cell, story: storyRepo.arrayOfSwipedStories[indexPath.row], userCorrect: false)
        }
        return cell
    }
    
    private func configureCell(cell: ResultTableViewCell, story: Story, userCorrect: Bool) {
        cell.storyLabel.text = story.title
        cell.correctAnsLabel.text = "Answer\n\(story.fact)"
        if userCorrect {
            cell.userAnsLabel.text = "You said\n\(String(story.fact))"
            cell.bgImage.image = correctUnderlayImage
            cell.bgImage.contentMode = .scaleAspectFill
        } else {
            cell.userAnsLabel.text = "You said\n\(String(!story.fact))"
            cell.bgImage.image = incorrectUnderlayImage
            cell.bgImage.contentMode = .scaleAspectFill
        }
        cell.storyURLasString = story.urlString
    }

}
