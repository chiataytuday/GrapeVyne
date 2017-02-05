//
//  ViewController.swift
//  StoryApp
//
//  Created by Umair Sharif on 12/28/16.
//  Copyright © 2016 usharif. All rights reserved.
//

import UIKit
import Koloda

private let customLightBlue = UIColor(red: 161/255, green: 203/255, blue: 255/255, alpha: 1.0)
private let customBlue = UIColor(red: 16/255, green: 102/255, blue: 178/255, alpha: 1.0)
private let customOrange = UIColor(red: 255/255, green: 161/255, blue: 0/255, alpha: 1.0)

class ViewController: UIViewController {
    @IBOutlet weak var kolodaView: KolodaView!
    var dataSource : [CardView]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = customLightBlue
        dataSource = getDataSource()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        trueButton.setImage(#imageLiteral(resourceName: "btn_true_pressed"), for: .highlighted)
        falseButton.setImage(#imageLiteral(resourceName: "btn_false_pressed"), for: .highlighted)
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var trueButton: UIButton!
    
    @IBOutlet weak var falseButton: UIButton!
    
    // MARK: IBActions
    
    @IBAction func trueButton(_ sender: UIButton) {
        kolodaView.swipe(.right)
    }
    
    @IBAction func falseButton(_ sender: UIButton) {
        kolodaView.swipe(.left)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
    
    // MARK: Private functions
    
    private func getDataSource() -> [CardView] {
        var tempArray = StoryRepo().arrayOfStories
        var arrayOfCardViews : [CardView] = []
        
        while tempArray.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(tempArray.count)))
            let cardVC = Bundle.main.loadNibNamed("CardView", owner: nil, options: nil)?[0] as! CardView
            if tempArray.count % 2 == 0 {
                cardVC.backgroundColor = customBlue
            } else {
                cardVC.backgroundColor = customOrange
            }
            cardVC.titleLabel.text = tempArray[randomIndex].title
            cardVC.titleLabel.textColor = UIColor.white
            arrayOfCardViews.append(cardVC)
            tempArray.remove(at: randomIndex)
        }
        return arrayOfCardViews
    }
    
}

// MARK: KolodaViewDelegate

extension ViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
    }
}


// MARK: KolodaViewDataSource

extension ViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return dataSource!.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return dataSource![index]
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("SwipeOverlayView",
                                                  owner: self, options: nil)?[0] as? OverlayView
    }
}
