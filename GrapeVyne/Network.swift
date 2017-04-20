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

var OTCategories = [OTCategory]()
var OTStories = [Story]()

class OpenTriviaNetworkDB {
    private let baseURL = "https://opentdb.com/"
    
    public func getCategories() {
        Alamofire.request("\(baseURL)api_category.php").responseJSON(completionHandler: {response in
            if let data = response.data {
                let json = JSON(data: data)
                let a = json["trivia_categories"]
                for (_, subJson) in a {
                    let catTitle = String(describing: subJson["name"])
                    let catIdString = String(describing: subJson["id"])
                    let catIdInt = Int(catIdString)!
                    OTCategories.append(OTCategory(title: catTitle, id: catIdInt))
                }
            }
        })
    }
    
    public func getStories(amount: Int, categoryId: Int?) {
        var categoryIdString = ""
        if let categoryIdInt = categoryId {
            categoryIdString = String(categoryIdInt)
        }
        let parameters: Parameters = [
            "amount" : String(amount),
            "category" : categoryIdString,
            "type" : "boolean"
        ]
        Alamofire.request("\(baseURL)/api.php", method: .get, parameters: parameters).responseJSON(completionHandler: {response in
            if let data = response.data {
                let json = JSON(data: data)
                for (_, subJson) in json["results"] {
                    let storyTitle = String(describing: subJson["question"])
                    let storyFactString = String(describing: subJson["correct_answer"])
                    let storyFactBool = determineStoryReliable(factString: storyFactString)!
                    OTStories.append(Story(title: storyTitle, url: "", fact: storyFactBool))
                }
            }
        })
    }
}


class Network {
    private let baseURL = "http://www.snopes.com/category/facts/"
    
    public func getCategories(completion: @escaping (_ array: [Category]) -> Void) {
        var array = [Category]()
        Alamofire.request(baseURL).responseString(queue: DispatchQueue.main, encoding: String.Encoding.utf8, completionHandler: {response in
            if let html = response.result.value {
                array = self.scrapeCategories(html: html)
            }
            completion(array)
        })
    }
    
    public func isValidCategory(category: Category, completion: @escaping (_ flag: Bool) -> Void) {
        var isValid = false
        Alamofire.request(category.url).responseString(completionHandler: {response in
            if let html = response.result.value {
                let stories = self.scrapeStories(html: html)
                if stories.count > 0 {
                    isValid = true
                }
            }
            completion(isValid)
        })
    }
    
    public func getStoriesFor(category: Category, completion:  @escaping (_ array: [Story]) -> Void) {
        var array = [Story]()
        Alamofire.request(category.url).responseString(completionHandler: { response in
            if let html = response.result.value {
                array = self.scrapeStories(html: html)
            }
            var count = 0
            var parsedArray = [Story]()
            for story in array {
                self.getFactValueFor(story: story, completion: { story in
                    count += 1
                    parsedArray.append(story)
                    if count == array.count {
                        completion(parsedArray)
                    }
                })
            }
        })
    }
    
    public func getFactValueFor(story: Story, completion: @escaping (_ story: Story) -> Void) {
        var parsedStory = story
        Alamofire.request(story.url).responseString(completionHandler: { response in
            if let html = response.result.value {
                if let factStringValue = self.scrapeFactValue(html: html) {
                    if let fact = determineStoryReliable(factString: factStringValue) {
                        parsedStory.fact = fact
                    }
                }
            }
            completion(parsedStory)
        })
    }
    
    private func scrapeFactValue(html: String) -> String? {
        var ratingString: String?
        if let doc = Kanna.HTML(html: html, encoding: .utf8) {
            for article in doc.xpath("/html/body/main/section/div[2]/div/article/div[4]/div[1]/span") {
                if let rating = article.text {
                    ratingString = rating
                }
            }
            if ratingString == nil {
                for article in doc.xpath("/html/body/main/section/div[2]/div/article/div[4]/div[2]/span") {
                    if let rating = article.text {
                        ratingString = rating
                    }
                }
            }
        }
        return ratingString
    }
    
    private func scrapeStories(html: String) -> [Story] {
        var _arrayOfStories = [Story]()
        if let doc = Kanna.HTML(html: html, encoding: .utf8) {
            for story in doc.xpath("//*[@id='main-list']/article/a") {
                var parsedStory = Story(title: "", url: "", fact: false)
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
                    _arrayOfStories.append(parsedStory)
                }
            }
        }
        return _arrayOfStories
    }
    
    private func scrapeCategories(html: String) -> [Category] {
        var _arrayOfCategories = [Category]()
        if let doc = Kanna.HTML(html: html, encoding: .utf8) {
            for category in doc.xpath("//*[@id='menu-archives-subnavigation']/li/a") {
                var parsedCategory = Category(title: "", url: "", stories: nil)
                if let url = category["href"] {
                    parsedCategory.url = url
                }
                if let title = category.text {
                    parsedCategory.title = title
                }
                _arrayOfCategories.append(parsedCategory)
            }
        }
        return _arrayOfCategories
    }
}

fileprivate func determineStoryReliable(factString: String) -> Bool? {
    switch factString {
    case "True", "true", "mtrue":
        return true
    case "False", "false", "mfalse":
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
