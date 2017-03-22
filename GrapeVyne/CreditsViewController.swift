//
//  CreditsViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/21/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {
    @IBOutlet weak var creditTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        creditTextView.text = "Creator: Umair Sharif\n\nWeb Scraping: Walid Sharif\n\nDesigns: Daniel Haidermota\n\nOriginal idea: Eric Schwaber"
        
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
