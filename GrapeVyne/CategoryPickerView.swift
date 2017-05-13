//
//  CategoryPickerView.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 5/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import PickerView

class CategoryPickerView: UIView {
    @IBOutlet weak var pickerView: PickerView!
    @IBOutlet weak var doneButton: UIButton!
    var doneButtonAction: (() -> Void)? = nil
    
    @IBAction func doneButton(_ sender: UIButton) {
        if let tapped = doneButtonAction {
            tapped()
        }
    }
    
}
