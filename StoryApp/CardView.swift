//
//  CardView.swift
//  StoryApp
//
//  Created by Umair Sharif on 1/4/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

class CardView: UIView {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var factLabel: UILabel!
    
class func instanceFromNib() -> UIView {
        return UINib(nibName: "CardView.xib", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
