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

class SnopesScrapeNetwork {
    private let factCheckURL = "http://www.snopes.com/category/facts/page/"
    private let whatsNewURL = "http://www.snopes.com/whats-new/page/"
    private let hotFiftyURL = "http://www.snopes.com/50-hottest-urban-legends/"
    var arrayOfParsedStories = [Story]()
    
    public func prepareDB() {
        let pageNum = 15
        let managedObject = CoreDataManager.fetchModel(entity: "CDStory")
        if managedObject.isEmpty { // Nothing in Core Data
            for i in 0...pageNum {
                let tempArray = getStoriesFor(url: "\(factCheckURL)\(i)")
                for story in tempArray {
                    let parsedStory = getFactValueFor(story: story)
                    arrayOfParsedStories.append(parsedStory)
                    CoreDataManager.writeToModel(story)
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
    }
    
    private func foo() {
        var i = 1
        var presentationArray = [Story]()
        while presentationArray.count < 30 {
            if arrayOfParsedStories.count <= 0 {
                let tempArray = getStoriesFor(url: "\(factCheckURL)\(i)")
                for story in tempArray {
                    arrayOfParsedStories.append(getFactValueFor(story: story))
                }
                i += 1
            }
            let randBool = randomBool()
            var story = getStory(value: randBool)
            if story != nil {
                presentationArray.append(story!)
            } else {
                while story?.fact != randBool {
                    let tempArray = getStoriesFor(url: "\(factCheckURL)\(i)")
                    for story in tempArray {
                        let storyWithFact = getFactValueFor(story: story)
                        arrayOfParsedStories.append(storyWithFact)
                    }
                    i += 1
                    story = getStory(value: randBool)
                }
                presentationArray.append(story!)
            }
        }
    }
    
    private func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
    
    private func getStory(value: Bool) -> Story? {
        var returnStory: Story?
        for story in arrayOfParsedStories {
            if story.fact == value {
                let s = story
                if let index = arrayOfParsedStories.index(where: {$0.title == story.title}) {
                    arrayOfParsedStories.remove(at: index)
                }
                returnStory = s
                break
            }
        }
        return returnStory
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
    
    public func getFactValueFor(story: Story) -> Story{
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
    
    // Mark: Unused category methods
    private func unusedMethods() {
//    public func getCategories(completion: @escaping (_ array: [Category]) -> Void) {
//        Alamofire.request(baseURL).responseString(queue: DispatchQueue.main, encoding: String.Encoding.utf8, completionHandler: {response in
//            var array = [Category]()
//            if let html = response.result.value {
//                array = self.scrapeCategories(html: html)
//            }
//            completion(array)
//        })
//    }
//    
//    public func isValidCategory(category: Category, completion: @escaping (_ flag: Bool) -> Void) {
//        var isValid = false
//        Alamofire.request(category.url!).responseString(completionHandler: {response in
//            if let html = response.result.value {
//                let stories = self.scrapeStories(html: html)
//                if stories.count > 0 {
//                    isValid = true
//                }
//            }
//            completion(isValid)
//        })
//    }
//    
//    public func getStoriesFor(category: Category, completion:  @escaping (_ array: [Story]) -> Void) {
//        var pageNum = 1
//        let sesh = URLSession(configuration: .default)
//        var hasFailed = false
//        repeat {
//            let response = sesh.synchronousDataTask(with: URL(string: "\(category.url!)/page/\(pageNum)")!).1
//            if let httpResponse = response as? HTTPURLResponse {
//                if httpResponse.statusCode == 200 {
//                    pageNum += 1
//                } else if httpResponse.statusCode >= 400 {
//                    hasFailed = true
//                }
//            }
//        } while !hasFailed
//        
//        var arrayOfStories = [Story]()
//        var count = 0
//        for i in 0...pageNum {
//            self.makeRequestFor(category: category, pageNum: i, completion: {array in
//                count += 1
//                for story in array {
//                    arrayOfStories.append(story)
//                }
//                if count == pageNum {
//                    completion(arrayOfStories)
//                }
//            })
//        }
//    }
//    
//    private func makeRequestFor(category: Category, pageNum: Int, completion:  @escaping (_ array: [Story]) -> Void) {
//        Alamofire.request("\(category.url!)/page/\(pageNum)").responseString(completionHandler: { response in
//            var array = [Story]()
//            if let html = response.result.value {
//                array = self.scrapeStories(html: html)
//            }
//            var count = 0
//            var parsedArray = [Story]()
//            
//            if !array.isEmpty {
//                for story in array {
//                    self.getFactValueFor(story: story, completion: { story in
//                        count += 1
//                        parsedArray.append(story)
//                        if count == array.count {
//                            completion(parsedArray)
//                        }
//                    })
//                }
//            } else {
//                completion(parsedArray)
//            }
//        })
//    }
//    
//    private func scrapeCategories(html: String) -> [Category] {
//        var _arrayOfCategories = [Category]()
//        if let doc = Kanna.HTML(html: html, encoding: .utf8) {
//            for category in doc.xpath("//*[@id='menu-archives-subnavigation']/li/a") {
//                var parsedCategory = Category(title: "", id: nil, url: "", stories: nil)
//                if let url = category["href"] {
//                    parsedCategory.url = url
//                }
//                if let title = category.text {
//                    parsedCategory.title = title
//                }
//                _arrayOfCategories.append(parsedCategory)
//            }
//        }
//        return _arrayOfCategories
//    }
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

extension String {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print(error)
            return nil
        }
    }
    var html2String: String {
        //return html2AttributedString?.string ?? ""
        return html2AttributedString?.string.replacingOccurrences(of: "\\", with: "") ?? ""
    }
}

//class OpenTriviaDBNetwork {
//    private let sessionTokenUserDefaultsKey = "SessionToken"
//    private let userDefaults = UserDefaults.standard
//    private let baseURL = "https://opentdb.com/"
//    
//    public func getCategories(completion: @escaping (_ array: [Category]) -> Void) {
//        Alamofire.request("\(baseURL)api_category.php").responseJSON(completionHandler: {response in
//            var array = [Category]()
//            if let data = response.data {
//                let json = JSON(data: data)
//                let jsonArray = json["trivia_categories"]
//                for (_, subJson) in jsonArray {
//                    if let catTitle = subJson["name"].string, let catIdInt = subJson["id"].int {
//                        array.append(Category(title: catTitle, id: catIdInt, url: nil, stories: nil))
//                    }
//                }
//            }
//            completion(array)
//        })
//    }
//    
//    public func getRandomStories(amount: Int, returnExhausted: Bool, completion: @escaping (_ array: [Story]?) -> Void) {
//        getStoriesFor(categoryId: nil, amount: amount, returnExhausted: returnExhausted, completion: {array in
//            completion(array)
//        })
//    }
//    
//    public func getStoriesFor(categoryId: Int?, amount: Int, returnExhausted: Bool, completion:  @escaping (_ array: [Story]?) -> Void) {
//        var categoryIdString = ""
//        if let categoryIdInt = categoryId {
//            categoryIdString = String(categoryIdInt)
//        }
//        var parameters: Parameters = [
//            "amount" : String(amount),
//            "category" : categoryIdString,
//            "type" : "boolean",
//            "token" : ""
//        ]
//        
//        if let token = userDefaults.string(forKey: sessionTokenUserDefaultsKey) { // Token not nil, saved in memory
//            parameters["token"] = token
//            self.makeRequestForStories(parameters, returnExhausted: returnExhausted, completion: {json in
//                var array = [Story]()
//                if json != nil {
//                    for (_, subJson) in json!["results"] {
//                        if let storyTitle = subJson["question"].string?.html2String,
//                            let storyFactString = subJson["correct_answer"].string,
//                            let storyFactBool = determineStoryReliable(factString: storyFactString) {
//                            array.append(Story(title: storyTitle, url: nil, fact: storyFactBool))
//                        }
//                    }
//                    completion(array)
//                } else {
//                    completion(nil)
//                }
//                
//            })
//        }
//        guard userDefaults.string(forKey: sessionTokenUserDefaultsKey) != nil else { // Token is nil, not saved in memory
//            getSessionToken(completion: {token in
//                parameters["token"] = token
//                self.userDefaults.set(token, forKey: self.sessionTokenUserDefaultsKey)
//                self.makeRequestForStories(parameters, returnExhausted: returnExhausted, completion: {json in
//                    var array = [Story]()
//                    if json != nil {
//                        for (_, subJson) in json!["results"] {
//                            if let storyTitle = subJson["question"].string?.html2String,
//                                let storyFactString = subJson["correct_answer"].string,
//                                let storyFactBool = determineStoryReliable(factString: storyFactString) {
//                                array.append(Story(title: storyTitle, url: nil, fact: storyFactBool))
//                            }
//                        }
//                        completion(array)
//                    } else {
//                        completion(nil)
//                    }
//                })
//            })
//            return
//        }
//    }
//    
//    private func makeRequestForStories(_ params: Parameters, returnExhausted: Bool, completion: @escaping (_ json: JSON?) -> Void) {
//        let sesh = URLSession(configuration: .default)
//        
//        var responseCode = 0
//        let category = params["category"] as! String
//        var amountString = params["amount"] as! String
//        repeat {
//            let url = URL(string: "https://opentdb.com/api.php?amount=\(amountString)&category=\(category)&type=boolean")!
//            if let data = sesh.synchronousDataTask(with: url).0 {
//                let json = JSON(data: data)
//                if let rCode = json["response_code"].int {
//                    responseCode = rCode
//                }
//            }
//            if let amountNum = Int(amountString) {
//                let newAmountNum = amountNum - 1
//                if newAmountNum <= 0 { // Assuming the API would not have a category with at least one question
//                    //completion(nil)
//                }
//                amountString = String(newAmountNum)
//            }
//        } while responseCode != 0
//        var copyParams = params
//        copyParams["amount"] = amountString
//        
//        Alamofire.request("\(self.baseURL)/api.php", method: .get, parameters: copyParams).responseJSON(completionHandler: {response in
//            if let data = response.data {
//                let json = JSON(data: data)
//                if let responseCode = json["response_code"].int {
//                    switch (responseCode) {
//                    case 0:
//                        // We guc, return the JSON
//                        completion(json)
//                    case 1: break
//                    // No Results: Could not return results. The API doesn't have enough questions for your query. (Ex. Asking for 50 Questions in a Category that only has 20.)
//                    case 2: break
//                    // Code 2: Invalid Parameter Contains an invalid parameter. Arguements passed in aren't valid. (Ex. Amount = Five)
//                    case 3: // Token Not Found: Session Token does not exist.
//                        self.getSessionToken(completion: {token in
//                            var copyParams = params
//                            copyParams["token"] = token
//                            self.userDefaults.set(token, forKey: self.sessionTokenUserDefaultsKey)
//                            self.makeRequestForStories(copyParams, returnExhausted: returnExhausted, completion: {json in
//                                completion(json)
//                            })
//                        })
//                    case 4: // Token Empty: Session Token has returned all possible questions for the specified query. Resetting the Token is necessary.
//                        if returnExhausted {
//                            let oldToken = params["token"] as! String
//                            self.resetSessionToken(token: oldToken, completion: {newToken in
//                                var copyParams = params
//                                copyParams["token"] = newToken
//                                self.makeRequestForStories(copyParams, returnExhausted: returnExhausted, completion: {json in
//                                    completion(json)
//                                })
//                            })
//                        } else {
//                            completion(nil)
//                        }
//                        
//                    default:
//                        return
//                    }
//                }
//            }
//        })
//    }
//    
//    private func getSessionToken(completion:  @escaping (_ token: String) -> Void) {
//        Alamofire.request("\(baseURL)api_token.php?command=request").responseJSON(completionHandler: {response in
//            var sessionToken = ""
//            if let data = response.data {
//                let json = JSON(data: data)
//                if let responseCode = json["response_code"].int {
//                    if responseCode == 0 {
//                        if let token = json["token"].string {
//                            sessionToken = token
//                        }
//                    }
//                }
//            }
//            completion(sessionToken)
//        })
//    }
//    
//    private func resetSessionToken(token : String, completion:  @escaping (_ newToken: String) -> Void) {
//        Alamofire.request("\(baseURL)api_token.php?command=reset&token=\(token)").responseJSON(completionHandler: {response in
//            var sessionToken = ""
//            if let data = response.data {
//                let json = JSON(data: data)
//                if let responseCode = json["response_code"].int {
//                    if responseCode == 0 {
//                        if let token = json["token"].string {
//                            sessionToken = token
//                        }
//                    }
//                }
//            }
//            completion(sessionToken)
//        })
//    }
//}
