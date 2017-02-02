//
//  UserDefaultsManager.swift
//  StoryApp
//
//  Created by Umair Sharif on 2/1/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    private static let hasNetworkDataKey = "networkDataKey"
    private static let trueDataKey = "trueDataKey"
    private static let falseDataKey = "falseDataKey"
    
    static var hasNetworkData : Bool {
        get {
            return UserDefaults.standard.bool(forKey: hasNetworkDataKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasNetworkDataKey)
        }
    }
    
    static var trueData : Data {
        get {
            return UserDefaults.standard.data(forKey: trueDataKey)!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: trueDataKey)
        }
    }
    
    static var falseData : Data {
        get {
            return UserDefaults.standard.data(forKey: falseDataKey)!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: falseDataKey)
        }
    }
}
