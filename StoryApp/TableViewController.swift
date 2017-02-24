//
//  TableViewController.swift
//  StoryApp
//
//  Created by Umair Sharif on 2/5/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import SafariServices

private let customLightGray = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1.0)

class ResultTableViewCell: UITableViewCell {
    var storyURLasString = ""
    var parentVC : TableViewController?
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var correctAnsLabel: UILabel!
    @IBOutlet weak var userAnsLabel: UILabel!
    
    @IBAction func linkButton(_ sender: UIButton) {
        let svc = SFSafariViewController(url: URL(string: storyURLasString)!)
        parentVC?.present(svc, animated: true, completion: nil)
    }
    
}

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.textAlignment = .center
        if section == 0 {
            headerLabel.text = "Correct"
        } else if section == 1 {
            headerLabel.text = "Incorrect"
        }
        return headerLabel
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var str = ""
        if section == 0 {
            str = "Correct"
        } else if section == 1 {
            str = "Incorrect"
        }
        return str
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var retVal = 0
        if section == 0 {
            retVal = storyRepo.arrayOfCorrectStories.count
        } else if section == 1 {
            retVal = storyRepo.arrayOfIncorrectStories.count
        }
        return retVal
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    @IBAction func doneButton(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Private functions
    
}
