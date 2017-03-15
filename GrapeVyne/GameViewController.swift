//
//  GameViewController.swift
//  StoryApp
//
//  Created by Umair Sharif on 12/28/16.
//  Copyright © 2016 usharif. All rights reserved.
//

import UIKit
import Koloda

// MARK: Global properties
// Color Config
private let viewBackgroundColor = UIColor.black
private let cardViewTextColor = UIColor.white
private let timerLabelTextColor = UIColor.white
private let noMoreCardsLabelTextColor = UIColor.white
private let countDownLabelTextColor = UIColor.white
private let timeEndingWarningColor = CustomColor.red
// Card Config
let cardCornerRadius : CGFloat = 20
// Animation Times
private let instructionAnimationDuration = 0.8
private let countDownAnimationDuration = 0.4
private let gameTimerAnimationDuration = 0.2
private let revealAnimationDuration = 0.3
// Taptic Engine
private let cardSwipeTaptic = UISelectionFeedbackGenerator()
private let gameFinishTaptic = UINotificationFeedbackGenerator()
//Swipe Sensitivity
private let swipeSensitivityPercentage : CGFloat = 20/100

class GameViewController: UIViewController {
    var dataSource : [CardView]?
    var gameTime = 60
    var gameTimer = Timer()
    var countDownTime = 5
    var countDownTimer = Timer()
    var blurEffectView = UIVisualEffectView()
    let instructionView = Bundle.main.loadNibNamed("Instruction", owner: nil, options: nil)?[0] as! UIView
    
    // MARK: IBOutlets
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var noMoreCardsLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = viewBackgroundColor

        dataSource = getDataSource()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        modalTransitionStyle = appModalTransitionStyle
        configureViewUI()
        //game starts with this completion handler
        view.insertSubview(instructionView, belowSubview: countDownLabel)
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {started in self.updateCountDownTimer()})
    }
    
    // MARK: IBActions
    
    // MARK: Private functions
    
    private func configureViewUI() {
        kolodaView.layer.cornerRadius = cardCornerRadius
        
        if (dataSource?.isEmpty)! {
            noMoreCardsLabel.isHidden = false
        } else {
            noMoreCardsLabel.isHidden = true
        }
        
        configureCardBlurEffectView()
        
        countDownLabel.textColor = countDownLabelTextColor
        countDownLabel.text = String(countDownTime)
        noMoreCardsLabel.textColor = noMoreCardsLabelTextColor
        
        timerLabel.textColor = timerLabelTextColor
        updateTimerLabel()
    }
    
    private func configureCardBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = kolodaView.layer.cornerRadius
        blurEffectView.layer.masksToBounds = true
        blurEffectView.frame = kolodaView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        kolodaView.addSubview(blurEffectView)
    }
    
    private func getDataSource() -> [CardView] {
        var tempArray = storyRepo.arrayOfStories
        var arrayOfCardViews : [CardView] = []
        
        while tempArray.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(tempArray.count)))
            let cardView = configureCardUI(title: tempArray[randomIndex].title, arrayCount: tempArray.count)
            arrayOfCardViews.append(cardView)
            tempArray.remove(at: randomIndex)
        }
        return arrayOfCardViews
    }
    
    private func configureCardUI(title: String, arrayCount: Int) -> CardView {
        let cardView = Bundle.main.loadNibNamed("CardView", owner: nil, options: nil)?[0] as! CardView
        cardView.titleLabel.text = title
        
        cardView.layer.cornerRadius = cardCornerRadius
        cardView.titleLabel.textColor = cardViewTextColor
        
        return cardView
    }
    
    private func updateCountDownTimer() {
        if countDownTime > 1 {
            countDownTime -= 1
            if countDownTime <= 2 {
                //remove instructions
                UIView.animate(withDuration: instructionAnimationDuration, animations: {self.instructionView.alpha = 0}, completion: {finished in self.instructionView.removeFromSuperview()})
            }
            countDownLabel.pushTransitionFromBottomWith(duration: countDownAnimationDuration)
            countDownLabel.text = String(countDownTime)
        } else {
            //end timer
            //start game
            startGame()
        }
    }
    
    private func updateGameTimer() {
        countDownLabel.isHidden = true
        UIView.animate(withDuration: revealAnimationDuration, animations: {self.blurEffectView.effect = nil}, completion: {finished in self.blurEffectView.removeFromSuperview()})
        if gameTime > 0 {
            gameTime -= 1
            updateTimerLabel()
        } else {
            //end game
            endGame()
        }
    }
    
    private func updateTimerLabel() {
        if gameTime < 11 {
            timerLabel.textColor = timeEndingWarningColor
        }
        var concatStr = ""
        if gameTime % 60 < 10 {
            concatStr = "0"
        }
        let minutes = String(gameTime / 60)
        let seconds = String(gameTime % 60)
        
        //timerLabel.pushTransitionFromBottomWith(duration: gameTimerAnimationDuration)
        timerLabel.text = "\(minutes):\(concatStr)\(seconds)"
    }
    
    // MARK: Class functions
    
    func startGame() {
        countDownLabel.pushTransitionFromBottomWith(duration: countDownAnimationDuration)
        countDownLabel.text = "Go!"
        countDownTimer.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {started in self.updateGameTimer()})
    }
    
    func endGame() {
        gameTimer.invalidate()
        gameFinishTaptic.notificationOccurred(.success)
        let resultTableVC = storyboard?.instantiateViewController(withIdentifier: "ResultTableViewController") as! ResultTableViewController
        resultTableVC.modalTransitionStyle = self.modalTransitionStyle
        present(resultTableVC, animated: true, completion: nil)
    }
}

// MARK: Animations

extension UIView: CAAnimationDelegate {
    
    func pushTransitionFromTopWith(duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromTop
        animation.duration = duration
        self.layer.add(animation, forKey: kCATransitionPush)
    }
    
    func pushTransitionFromBottomWith(duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromBottom
        animation.duration = duration
        self.layer.add(animation, forKey: kCATransitionPush)
    }
}

// MARK: KolodaViewDelegate

extension GameViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        endGame()
        noMoreCardsLabel.isHidden = false
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        //add .up to pass card
        return [.left, .right]
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        //Use the card display title to store the story title
        let storyTitle = (dataSource?[index].titleLabel.text!)!
        //Get the story object by searching on the story title
        let storyObject = CoreDataManager.fetchObject(entity: "CDStory", title: storyTitle)
        
        //Get the story's other properties
        let storyFactValue = storyObject.value(forKey: "fact") as! Bool
        let storyURLString = storyObject.value(forKey: "urlString") as! String
        
        //Create a temporary story property
        let tempStory = Story(title: storyTitle, fact: storyFactValue, urlStr: storyURLString)
        
        //Determine result of user action
        let userAnswer = isUserCorrectFor(factValue: storyFactValue, swipeDirection: direction)
        
        performSwipeResultAnimationFor(userAns: userAnswer)
        storyRepo.arrayOfSwipedStories.append(tempStory)
        updateResultArrayFor(userAns: userAnswer, story: tempStory)
        
        //Finally, delete the story from memory
        CoreDataManager.deleteObject(entity: "CDStory", title: storyTitle)
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
        cardSwipeTaptic.selectionChanged()
        return true
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return swipeSensitivityPercentage
    }
    
    // MARK: KolodaViewDelegate private functions
    
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
    
    private func performSwipeResultAnimationFor(userAns: Bool) {
        let resultView = Bundle.main.loadNibNamed("SwipeOverlayResultView", owner: nil, options: nil)?[0] as! SwipeOverlayResultView
        resultView.setupAccordingTo(userAnswer: userAns)
        resultView.alpha = 0
        resultView.center = kolodaView.center
        
        self.view.addSubview(resultView)
        UIView.animate(withDuration: revealAnimationDuration, delay: 0, options: .curveEaseOut,
                       animations: {
                        resultView.alpha = 1},
                       completion: { finished in
                        UIView.animate(withDuration: revealAnimationDuration * 2, delay: 0,
                                       animations: {
                                        resultView.alpha = 0},
                                       completion: { finished in
                                        resultView.removeFromSuperview()
                        })
        })
    }
    
    private func updateResultArrayFor(userAns: Bool, story: Story) {
        if (userAns) {
            storyRepo.arrayOfCorrectStories.append(story)
        } else {
            storyRepo.arrayOfIncorrectStories.append(story)
        }
    }
}


// MARK: KolodaViewDataSource

extension GameViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return dataSource!.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return dataSource![index]
    }
}
