//
//  Network.swift
//  StoryApp
//
//  Created by Umair Sharif on 1/28/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import Foundation
import Alamofire
import Kanna
import SwiftyJSON
import Async

class SnopesScrapeNetwork {
    private let factCheckURL = "https://www.snopes.com/fact-check/"
    private let whatsNewURL = "https://www.snopes.com/whats-new/"
    private let hotFiftyURL = "https://www.snopes.com/50-hottest-urban-legends/"
    let pageNum = 15
    var counter = 0
    
    public func prepareDB() -> [Story] {
        var arrayOfParsedStories = [Story]()
        let managedObject = CoreDataManager.fetchModel(entity: "CDStory")
        if managedObject.isEmpty { // Nothing in Core Data
            for i in 1...pageNum {
                let tempArray = getStoriesFor(url: "\(factCheckURL)\(i)")
                for story in tempArray {
                    let parsedStory = getFactValueFor(story: story)
                    if let storyWithID = CoreDataManager.writeToModel(parsedStory) {
                        arrayOfParsedStories.append(storyWithID)
                    }
                }
            }
        } else if managedObject.count > 1500 {// Automatically refresh database
            for object in managedObject {
                CoreDataManager.deleteObjectBy(id: object.objectID)
            }
            for i in 1...pageNum {
                let tempArray = getStoriesFor(url: "\(factCheckURL)\(i)")
                for story in tempArray {
                    let parsedStory = getFactValueFor(story: story)
                    if let storyWithID = CoreDataManager.writeToModel(parsedStory) {
                        arrayOfParsedStories.append(storyWithID)
                    }
                }
            }
        } else { // Something in Core Data
            print("Stories in CD \(managedObject.count)")
            for object in managedObject {
                let title = object.value(forKey: "title") as! String
                let factValue = object.value(forKey: "fact") as! Bool
                let urlString = object.value(forKey: "urlString") as! String
                let id = object.objectID
                let tempStory = Story(title: title, url: urlString, fact: factValue, id: id)
                arrayOfParsedStories.append(tempStory)
            }
        }
        return arrayOfParsedStories
    }
    
    public func getStories() -> [Story] {
        var arrayOfParsedStories = [Story]()
        counter += 1
        let url = "\(factCheckURL)" + "page/" + "\(pageNum+counter)/"
        let tempArray = getStoriesFor(url: url)
        for story in tempArray {
            let parsedStory = getFactValueFor(story: story)
            if let storyWithID = CoreDataManager.writeToModel(parsedStory) {
                arrayOfParsedStories.append(storyWithID)
            }
        }
        return arrayOfParsedStories
    }
    
    public func getStoriesFor(url: String) -> [Story] {
        var array = [Story]()
        let session = URLSession(configuration: .default)
        if let data = session.synchronousDataTask(with: URL(string: url)!).0,
            let html = String(data: data, encoding: .utf8) {
            array = self.scrapeStories(html: html)
        }
        return array
    }
    
    public func getFactValueFor(story: Story) -> Story {
        var parsedStory = story
        let session = URLSession(configuration: .default)
        
        if let data = session.synchronousDataTask(with: URL(string: story.url)!).0,
            let html = String(data: data, encoding: .utf8) {
            if let factValueString = self.scrapeFactValue(html: html), let factValue = determineStoryReliable(factString: factValueString) {
                parsedStory.fact = factValue
            }
        }
        return parsedStory
    }
    
    private func scrapeFactValue(html: String) -> String? {
        var ratingString: String?
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            let xmlElement = doc.at_xpath("/html/body/main/section/div[2]/div/article/div[4]/div[1]/span", namespaces: nil)
            if let rating = xmlElement?.text {
                ratingString = rating
            }
            
            if ratingString == nil {
                let xmlElement = doc.at_xpath("/html/body/main/section/div[2]/div/article/div[4]/div[2]/span", namespaces: nil)
                if let rating = xmlElement?.text {
                    ratingString = rating
                }
            }
        }
        return ratingString
    }
    
    private func scrapeStories(html: String) -> [Story] {
        var _arrayOfStories = [Story]()
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            let stories = doc.css(".base-main .media-wrapper")
            
            for story in stories {
                let title = story.css(".title").first
                let url = story.css(".media.fact_check").first
                
                if let sureTitle = title?.text, let sureURL = url?["href"] {
                    if sureTitle.contains("?") {
                        if !sureTitle.containsIncorrectSyntaxQuestion() {
                            let story = Story(title: sureTitle, url: sureURL, fact: false, id: nil)
                            _arrayOfStories.append(story)
                        }
                    }
                }
                
            }
        }
        return _arrayOfStories
    }
}

fileprivate func determineStoryReliable(factString: String) -> Bool? {
    switch factString {
    case "TRUE", "MOSTLY TRUE":
        return true
    case "FALSE", "MOSTLY FALSE", "MIXTURE", "MISCAPTIONED", "UNPROVEN", "SCAM", "OUTDATED":
        return false
    default:
        return nil
    }
}

extension URLSession {
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

extension String {
    func containsIncorrectSyntaxQuestion() -> Bool {
        let incorrectSyntaxQuestionArray = ["what","why","when","where","how"]
        for string in incorrectSyntaxQuestionArray {
            if self.lowercased().contains(string) {
                return true
            }
        }
        return false
    }
}
