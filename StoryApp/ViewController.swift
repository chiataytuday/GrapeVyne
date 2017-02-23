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
private let customGreen =  UIColor(red: 0, green: 128/255, blue: 0, alpha: 1.0)
private let customRed = UIColor(red: 218/255, green: 0, blue: 0, alpha: 1.0)
private let cardViewBG = "news_paper"
private let animationDuration = 0.4

class ViewController: UIViewController {
    @IBOutlet weak var kolodaView: KolodaView!
    var dataSource : [CardView]?
    var countRight = 0
    var countWrong = 0
    var gameTime = 60
    var gameTimer = Timer()
    var countDownTime = 3
    var countDownTimer = Timer()
    var blurEffectView = UIVisualEffectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = customLightBlue
        dataSource = getDataSource()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.layer.cornerRadius = 20
        
        if (dataSource?.isEmpty)! {
            finishedLabel.isHidden = false
        } else {
            finishedLabel.isHidden = true
        }
        rightCounter.textColor = customGreen
        wrongCounter.textColor = customRed
        
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.98
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.layer.masksToBounds = true
        blurEffectView.frame = kolodaView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        kolodaView.addSubview(blurEffectView)
        
        countDownLabel.text = String(countDownTime)
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {started in self.updateCountDownTimer()})
        
        timerLabel.text = "\(gameTime)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var rightCounter: UILabel!
    @IBOutlet weak var wrongCounter: UILabel!
    @IBOutlet weak var finishedLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    
    // MARK: IBActions
    
    
    // MARK: Private functions
    
    private func getDataSource() -> [CardView] {
        var tempArray = storyRepo.arrayOfStories
        var arrayOfCardViews : [CardView] = []
        
        while tempArray.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(tempArray.count)))
            let cardVC = Bundle.main.loadNibNamed("CardView", owner: nil, options: nil)?[0] as! CardView
            cardVC.bgImageView.image = UIImage(named: cardViewBG)
            cardVC.bgImageView.clipsToBounds = true
            cardVC.titleLabel.text = tempArray[randomIndex].title
            cardVC.titleLabel.textColor = UIColor.black
            
            arrayOfCardViews.append(cardVC)
            tempArray.remove(at: randomIndex)
        }
        return arrayOfCardViews
    }
    
    private func updateCountDownTimer() {
        if countDownTime > 1 {
            countDownTime -= 1
            countDownLabel.pushTransition()
            countDownLabel.text = String(countDownTime)
        } else {
            //end timer
            //start game
            startGame()
        }
    }
    
    private func updateGameTimer() {
        countDownLabel.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {self.blurEffectView.alpha = 0}, completion: {finished in self.blurEffectView.removeFromSuperview()})
        if gameTime > 0 {
            gameTime -= 1
            timerLabel.pushTransitionWith(duration: 0.2)
            timerLabel.text = "\(gameTime)"
        } else {
            //end game
            stopGame()
        }
    }
    
    func startGame() {
        countDownLabel.pushTransition()
        countDownLabel.text = "Go!"
        countDownTimer.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {started in self.updateGameTimer()})
    }
    
    func stopGame() {
        gameTimer.invalidate()
        let tableVC = storyboard?.instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
        present(tableVC, animated: true, completion: nil)
    }
}

extension UIView: CAAnimationDelegate {
    func pushTransition() {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromTop
        animation.duration = animationDuration
        self.layer.add(animation, forKey: kCATransitionPush)
    }
    
    func pushTransitionWith(duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromTop
        animation.duration = duration
        self.layer.add(animation, forKey: kCATransitionPush)
    }
}

// MARK: KolodaViewDelegate

extension ViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        stopGame()
        finishedLabel.isHidden = false
        CoreDataManager.writeMetricToModel(entity: "Metrics", value: true)
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        //add .up to pass card
        return [.left, .right]
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        //Get the story title
        let storyTitle = (dataSource?[index].titleLabel.text!)!
        //Get the story object
        let storyObject = CoreDataManager.fetchObject(entity: "CDStory", title: storyTitle)
        //Get the story's properties
        let storyFactValue = storyObject.value(forKey: "fact") as! Bool
        //Determine result of user action
        let userAnswer = isUserCorrectFor(factValue: storyFactValue, swipeDirection: direction)
        
        updateCountersFor(userAns: userAnswer)
        performSwipeResultAnimationFor(userAns: userAnswer)
        updateResultArrayFor(userAns: userAnswer, index: index)
        
        //Finally, delete the story from memory
        CoreDataManager.deleteObject(entity: "CDStory", title: storyTitle)
    }
    
    private func isUserCorrectFor(factValue: Bool, swipeDirection: SwipeResultDirection) -> Bool {
        var isUserCorrect = false
        switch swipeDirection {
        case .right:
            if factValue {
                //User action correct
                isUserCorrect = true
            } else {
                //User action incorrect
                isUserCorrect = false
            }
        case .left:
            if factValue {
                //User action incorrect
                isUserCorrect = false
            } else {
                //User action correct
                isUserCorrect = true
            }
        default:
            break
        }
        return isUserCorrect
    }
    
    private func updateCountersFor(userAns: Bool) {
        if userAns {
            countRight += 1
            rightCounter.pushTransition()
            rightCounter.text = "\(countRight)"
        } else {
            countWrong += 1
            wrongCounter.pushTransition()
            wrongCounter.text = "\(countWrong)"
        }
    }
    
    private func performSwipeResultAnimationFor(userAns: Bool) {
        let resultView = Bundle.main.loadNibNamed("SwipeOverlayResultView", owner: nil, options: nil)?[0] as! SwipeOverlayResultView
        resultView.resultLabel.textColor = UIColor.white
        resultView.setupAccordingTo(userAnswer: userAns)
        resultView.alpha = 0
        resultView.resultImage.alpha = 0.85
        
        self.view.addSubview(resultView)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut,
                       animations: {
                        resultView.alpha = 1},
                       completion: { finished in
                        UIView.animate(withDuration: 0.6, delay: 0,
                                       animations: {
                                        resultView.alpha = 0},
                                       completion: { finished in
                                        resultView.removeFromSuperview()
                        })
        })
    }
    
    private func updateResultArrayFor(userAns: Bool, index: Int) {
        if (userAns) {
            storyRepo.arrayOfCorrectStories.append(storyRepo.arrayOfStories[index])
        } else {
            storyRepo.arrayOfIncorrectStories.append(storyRepo.arrayOfStories[index])
        }
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
}
