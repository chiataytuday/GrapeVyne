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
            
            let factValueString = scrapeFactValue(html: html)
            if let sureFactValueString = factValueString {
                if let sureFactValue = determineStoryReliable(factString: sureFactValueString) {
                    parsedStory.fact = sureFactValue
                }
            }
        }
        return parsedStory
    }
    
    private func scrapeFactValue(html: String) -> String? {
        guard let sureDoc = try? Kanna.HTML(html: html, encoding: .utf8) else { return nil }
        
        let mediaRating = sureDoc.css(".media.rating").first
        let rating = mediaRating?.css("h5").first
        
        return rating?.text
    }
    
    private func scrapeStories(html: String) -> [Story] {
        var stories = [Story]()
        
        guard let sureDoc = try? Kanna.HTML(html: html, encoding: .utf8) else { return [] }
        
        let storiesDoc = sureDoc.css(".base-main .media-wrapper")
        
        for storyDoc in storiesDoc {
            let title = storyDoc.css(".title").first
            let url = storyDoc.css(".media").first
            
            if let sureTitle = title?.text, let sureURL = url?["href"] {
                if sureTitle.contains("?") {
                    if !sureTitle.containsIncorrectSyntaxQuestion() {
                        let story = Story(title: sureTitle, url: sureURL, fact: false, id: nil)
                        stories.append(story)
                    }
                }
            }
            
        }
        
        return stories
    }
}

fileprivate func determineStoryReliable(factString: String) -> Bool? {
    switch factString {
    case "TRUE", "MOSTLY TRUE", "CORRECT ATTRIBUTION":
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
