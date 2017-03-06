//
//  SwipeOverlayResultView.swift
//  StoryApp
//
//  Created by Umair Sharif on 2/19/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

private let customGreen =  UIColor(red: 0, green: 128/255, blue: 0, alpha: 1.0)
private let customRed = UIColor(red: 218/255, green: 0, blue: 0, alpha: 1.0)
private let swipeCorrect =  CustomColor.swipeCorrectGreen
private let swipeIncorrect = CustomColor.swipeIncorrectRed

class SwipeOverlayResultView: UIView {

    @IBOutlet weak var resultImage: UIImageView!
    
    func setupAccordingTo(userAnswer: Bool) {
        resultImage.contentMode = .scaleAspectFill
        if userAnswer {
            resultImage.image = #imageLiteral(resourceName: "correctBanner")
        } else {
            resultImage.image = #imageLiteral(resourceName: "incorrectBanner")
        }
    }
}
