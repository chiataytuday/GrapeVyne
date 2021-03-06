//
//  GameViewController.swift
//  StoryApp
//
//  Created by Umair Sharif on 12/28/16.
//  Copyright © 2016 usharif. All rights reserved.
//

import UIKit
import Koloda
import TKSubmitTransitionSwift3

// MARK: Global properties
// Color Config
private let viewBackgroundColor = UIColor.black
private let cardViewTextColor = UIColor.white
private let timerLabelTextColor = UIColor.white
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
    var gameSetArray = [Story]()
    
    // MARK: IBOutlets
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = viewBackgroundColor
        modalTransitionStyle = appModalTransitionStyle
        
        dataSource = getDataSource()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        configureViewUI()
        instructionView.frame = view.bounds
        view.insertSubview(instructionView, belowSubview: countDownLabel)
        //game starts with this completion handler
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {started in self.updateCountDownTimer()})
    }
    
    // MARK: IBActions
    
    // MARK: Private functions
    
    private func configureViewUI() {
        kolodaView.layer.cornerRadius = cardCornerRadius
        
        configureCardBlurEffectView()
        
        countDownLabel.textColor = countDownLabelTextColor
        countDownLabel.text = String(countDownTime)
        
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
        var tempArray = gameSetArray
        var arrayOfCardViews : [CardView] = []
        
        while tempArray.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(tempArray.count)))
            let cardView = configureCardUI(story: tempArray[randomIndex], arrayCount: tempArray.count)
            arrayOfCardViews.append(cardView)
            tempArray.remove(at: randomIndex)
        }
        return arrayOfCardViews
    }
    
    private func configureCardUI(story: Story, arrayCount: Int) -> CardView {
        let cardView = Bundle.main.loadNibNamed("CardView", owner: nil, options: nil)?[0] as! CardView
        cardView.story = story
        cardView.titleLabel.text = story.title
        
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
        countDownLabel.text = "GO!"
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
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        //add .up to pass card
        return [.left, .right]
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if let cardAtIndex = dataSource?[index], let story = cardAtIndex.story, let storyID = story.id {
            let userAnswer = isUserCorrectFor(factValue: story.fact, swipeDirection: direction)
            performSwipeResultAnimationFor(userAns: userAnswer)
            storyRepo.arrayOfSwipedStories.append(story)
            updateResultArrayFor(userAns: userAnswer, story: story)
            CoreDataManager.deleteObjectBy(id: storyID)
        }
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
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return dataSource!.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return dataSource![index]
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension GameViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fadeInAnimator = TKFadeInAnimator()
        return fadeInAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fadeInAnimator = TKFadeInAnimator()
        return fadeInAnimator
    }
    
}
