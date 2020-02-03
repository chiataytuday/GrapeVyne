//
//  LoadingActivityView.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 4/7/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    let label = UILabel()
    let blurEffect = UIBlurEffect(style: .light)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(activityIndicator)
        vibrancyView.contentView.addSubview(label)
        activityIndicator.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            label.frame = CGRect(x: 50, y: 0, width: 160, height: 46)
            label.text = text?.uppercased()
            label.font = UIFont(name: "Gotham-Bold", size: 18.0)!
            label.textColor = UIColor.white
            
            self.frame = CGRect(x: superview.frame.midX - label.frame.width/2, y: superview.frame.midY - label.frame.height/2 , width: 160, height: 46)
            vibrancyView.frame = self.bounds
            
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            
            layer.cornerRadius = 15.0
            layer.masksToBounds = true
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
}
