//
//  InstructionViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/21/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

class InstructionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func doneButton(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
