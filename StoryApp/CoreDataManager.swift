//
//  CoreDataManager.swift
//  StoryApp
//
//  Created by Umair Sharif on 2/5/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class CoreDataManager {
    
    static func writeStoryToModel(entity: String, title: String, fact: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entity, in: context)
        let story = NSManagedObject(entity: entity!, insertInto: context)
        story.setValue(title, forKey: "title")
        story.setValue(fact, forKey: "fact")
        do {
            try context.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
//    static func updateModel(entity: String , valueToSet : Any, key : String) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: entity, in: context)
//        let day = NSManagedObject(entity: entity!, insertInto: context)
//        day.setValue(valueToSet, forKey: key)
//        do {
//            try context.save()
//        } catch let error as NSError  {
//            print("Could not save \(error), \(error.userInfo)")
//        }
//    }
    
    static func fetchModel(entity: String) -> [NSManagedObject] {
        var managedObject = [NSManagedObject]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        do {
            let results = try context.fetch(fetchRequest)
            managedObject = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return managedObject
    }
}
