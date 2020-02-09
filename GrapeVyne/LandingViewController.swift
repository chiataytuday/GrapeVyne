//
//  LandingViewController.swift
//  GrapeVyne
//
//  Created by Umair Sharif on 3/8/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import PickerView

class LandingViewController: UIViewController {
    private let questionButton = UIButton()
    private let titleImageView = UIImageView()
    private let centerImageView = UIImageView()
    private let playButton = UIButton()
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = appModalTransitionStyle
        loadSubviews()
        setupAutolayoutConstraints()
    }
    
    private func loadSubviews() {
        loadQuestionButton()
        loadTitleImageView()
        loadCenterImageView()
        loadPlayButton()
        loadActivityIndicatorView()
    }
    
    private func loadQuestionButton() {
        questionButton.translatesAutoresizingMaskIntoConstraints = false
        questionButton.setImage(UIImage(named: "question_button"), for: .normal)
        
        questionButton.addTarget(self, action: #selector(onTapQuestionButton), for: .touchUpInside)
        
        view.addSubview(questionButton)
    }
    
    private func loadTitleImageView() {
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        titleImageView.image = UIImage(named: "logo_text")
        
        view.addSubview(titleImageView)
    }
    
    private func loadCenterImageView() {
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        centerImageView.image = UIImage(named: "logo_icon")
        
        view.addSubview(centerImageView)
    }
    
    private func loadPlayButton() {
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.backgroundColor = CustomColor.customPurple
        playButton.titleLabel?.textAlignment = .center
        playButton.titleLabel?.attributedText = NSAttributedString(string: "Play".uppercased(), attributes: [NSAttributedString.Key.font : UIFont(name: "Gotham-Bold", size: 40.0)!])
        playButton.titleLabel?.textColor = .white
        playButton.setTitle("Play".uppercased(), for: .normal)
        playButton.setTitleColor(.white, for: .normal)
        playButton.layer.cornerRadius = 25
        
        playButton.addTarget(self, action: #selector(onTapPlayButton), for: .touchUpInside)
        
        view.addSubview(playButton)
    }
    
    private func loadActivityIndicatorView() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = CustomColor.customGreen
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        view.addSubview(activityIndicatorView)
        view.bringSubviewToFront(activityIndicatorView)
    }
    
    private func setupAutolayoutConstraints() {
        setupQuestionButtonAutolayoutConstraints()
        setupTitleImageViewAutolayoutConstraints()
        setupCenterImageViewAutolayoutConstraints()
        setupPlayButtonAutolayoutConstraints()
        setupActivityIndicatorViewAutolayoutConstraints()
    }
    
    private func setupQuestionButtonAutolayoutConstraints() {
        questionButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        questionButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        questionButton.widthAnchor.constraint(equalTo: questionButton.heightAnchor).isActive = true
        questionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
    
    private func setupTitleImageViewAutolayoutConstraints() {
        titleImageView.topAnchor.constraint(equalTo: questionButton.bottomAnchor, constant: 10).isActive = true
        titleImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupCenterImageViewAutolayoutConstraints() {
        centerImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        centerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupPlayButtonAutolayoutConstraints() {
        playButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        playButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25).isActive = true
    }
    
    private func setupActivityIndicatorViewAutolayoutConstraints() {
        activityIndicatorView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        activityIndicatorView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        activityIndicatorView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    @objc private func onTapQuestionButton() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let viewTutorialAction = UIAlertAction(title: "How To Play", style: .default, handler: {presentVC in
            let instructionVC = self.storyboard?.instantiateViewController(withIdentifier: "InstructionViewController") as! InstructionViewController
            self.present(instructionVC, animated: true, completion: nil)
        })
        
        let viewCreditsAction = UIAlertAction(title: "Credits", style: .default, handler: {presentVC in
            let creditsVC = self.storyboard?.instantiateViewController(withIdentifier: "CreditsViewController") as! CreditsViewController
            self.present(creditsVC, animated: true, completion: nil)
        })
        
        let refreshDBAction = UIAlertAction(title: "Refresh Database", style: .destructive, handler: { _ in
            let managedObject = CoreDataManager.fetchModel(entity: "CDStory")
            for object in managedObject {
                CoreDataManager.deleteObjectBy(id: object.objectID)
            }
            self.dismiss(animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(viewTutorialAction)
        optionMenu.addAction(viewCreditsAction)
        optionMenu.addAction(refreshDBAction)
        optionMenu.addAction(cancelAction)
        
        optionMenu.view.tintColor = CustomColor.customPurple
        present(optionMenu, animated: true, completion: nil)
    }
    
    @objc private func onTapPlayButton() {
        didStartLoading()
        var arrayToPass = [Story]()
        
        DispatchQueue.global().async {
            var randBool = self.randomBool()
            while arrayToPass.count < 30 {
                while !storyRepo.arrayOfStories.contains(where: {$0.fact == randBool}) {
                    storyRepo.arrayOfStories.append(contentsOf: snopesScrapeNetwork.getStories())
                }
                for story in storyRepo.arrayOfStories {
                    if story.fact == randBool {
                        arrayToPass.append(story)
                        if let index = storyRepo.arrayOfStories.firstIndex(where: {$0.id == story.id}) {
                            storyRepo.arrayOfStories.remove(at: index)
                        }
                        randBool = self.randomBool()
                        break
                    }
                }
            }
            
            DispatchQueue.main.sync { [weak self] in
                self?.leaveViewController(with: arrayToPass)
            }
        }
    }
    
    private func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
    
    private func leaveViewController(with: [Story]) {
//        playButton.startFinishAnimation(0 , completion: {
//            let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
//            gameVC.transitioningDelegate = self
//            gameVC.gameSetArray = with
//            self.present(gameVC, animated: true, completion: {
//                self.view.isUserInteractionEnabled = true
//            })
//        })
    }
    
    func didStartLoading() {
        self.view.isUserInteractionEnabled = false
        activityIndicatorView.startAnimating()
    }
    
    func didCancelLoading() {
        self.view.isUserInteractionEnabled = true
        activityIndicatorView.stopAnimating()
    }
}
