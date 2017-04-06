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

private let baseURL = "http://www.snopes.com/category/facts/"

class Network {
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
                if stories.count != 0 {
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
            completion(array)
        })
    }
    
    public func getFactValueFor(story: Story, completion: @escaping (_ story: Story) -> Void) {
        var parsedStory = story
        Alamofire.request(story.url).responseString(completionHandler: { response in
            if let html = response.result.value {
                if let factStringValue = self.scrapeFactValue(html: html) {
                    if let fact = self.determineStoryReliable(factString: factStringValue) {
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
                var parsedCategory = Category(title: "", url: "")
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
    
    private func determineStoryReliable(factString: String) -> Bool? {
        switch factString {
        case "True", "true", "mtrue":
            return true
        case "False", "false", "mfalse":
            return false
        default:
            return nil
        }
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
