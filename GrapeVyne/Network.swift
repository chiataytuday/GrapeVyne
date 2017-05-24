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
    private let factCheckURL = "http://www.snopes.com/category/facts/page/"
    private let whatsNewURL = "http://www.snopes.com/whats-new/page/"
    private let hotFiftyURL = "http://www.snopes.com/50-hottest-urban-legends/"
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
        let tempArray = getStoriesFor(url: "\(factCheckURL)\(pageNum+counter)")
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
        if let doc = Kanna.HTML(html: html, encoding: .utf8) {
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
        if let doc = Kanna.HTML(html: html, encoding: .utf8) {
            for story in doc.xpath("//*[@id='main-list']/article/a") {
                var parsedStory = Story(title: "", url: "", fact: false, id: nil)
                if let url = story["href"] {
                    parsedStory.url = url
                }
                let h2 = story.css("h2")
                for title in h2 {
                    if let text = title.text {
                        parsedStory.title = text
                    }
                }
                if parsedStory.title.contains("?") {
                    if !parsedStory.title.lowercased().containsIncorrectSyntaxQuestion() {
                        _arrayOfStories.append(parsedStory)
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
            if self.contains(string) {
                return true
            }
        }
        return false
    }
}
