//
//  ViewController.swift
//  StoryApp
//
//  Created by Umair Sharif on 12/28/16.
//  Copyright © 2016 usharif. All rights reserved.
//

import UIKit
import Koloda

class ViewController: UIViewController {
    @IBOutlet weak var kolodaView: KolodaView!
    
    var dataSource: [CardView] {
        let storyRepo = StoryRepo()
        var array : [CardView] = []
        
        for i in 0..<storyRepo.arrayOfStories.count {
            
            let cardVC = CardView()
            cardVC.nameLabel.text = storyRepo.arrayOfStories[i].name
            cardVC.textView.text = storyRepo.arrayOfStories[i].text
            cardVC.factLabel.text = "False"
            if storyRepo.arrayOfStories[i].fact! {
                cardVC.factLabel.text = "True"
            }
            array.append(cardVC)
        }
        return array
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        print("GAMEEEE OVERRRRR")
//        let position = kolodaView.currentCardIndex
//        
//        for i in 1...4 {
//            var s = UITextView(frame: CGRect(x: 20, y: 20, width: 100, height: 100))
//            s.text = storyRepo.getArray()[i].getText()
//            dataSource.append(s)
//        }
//        kolodaView.insertCardAtIndexRange(position..<position + 4, animated: true)
    }
    
    func koloda(koloda: KolodaView, didSelectCardAt index: Int) {
        UIApplication.shared.openURL(NSURL(string: "https://yalantis.com/")! as URL)
    }
}

extension ViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return dataSource.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return dataSource[index]
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView",
                                                  owner: self, options: nil)?[0] as? OverlayView
    }
}
