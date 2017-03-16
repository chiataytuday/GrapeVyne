//
//  SwipeOverlayResultView.swift
//  StoryApp
//
//  Created by Umair Sharif on 2/19/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

class SwipeOverlayResultView: UIView {

    @IBOutlet weak var resultImage: UIImageView!
    
    func setupAccordingTo(userAnswer: Bool) {
        if userAnswer {
            resultImage.image = #imageLiteral(resourceName: "correct")
        } else {
            resultImage.image = #imageLiteral(resourceName: "incorrect")
        }
    }
}
