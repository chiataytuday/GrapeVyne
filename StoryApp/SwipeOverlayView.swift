//
//  SwipeOverlayView.swift
//  StoryApp
//
//  Created by Umair Sharif on 2/1/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "overlay_true"
private let overlayLeftImageName = "overlay_false"
private let cornerRadius : CGFloat = 20

class SwipeOverlayView: OverlayView {
    
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                self.backgroundColor = UIColor.clear
                overlayImageView.image = UIImage(named: overlayLeftImageName)
                overlayImageView.frame = CGRect(x: self.frame.maxX - (self.frame.maxX / 3), y: -60, width: 150, height: 150)
                overlayImageView.contentMode = .scaleAspectFit
                overlayImageView.backgroundColor = UIColor.clear
                
            case .right? :
                self.backgroundColor = UIColor.clear
                overlayImageView.image = UIImage(named: overlayRightImageName)
                overlayImageView.frame = CGRect(x: -20, y: -60, width: 150, height: 150)
                overlayImageView.contentMode = .scaleAspectFit
                overlayImageView.backgroundColor = UIColor.clear
            default:
                overlayImageView.image = nil
            }
            
        }
    }
    
}
