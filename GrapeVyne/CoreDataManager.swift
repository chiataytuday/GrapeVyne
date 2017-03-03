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
    
    static func writeStoryToModel(entity: String, title: String, fact: Bool, urlStr: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entity, in: context)
        let story = NSManagedObject(entity: entity!, insertInto: context)
        story.setValue(title, forKey: "title")
        story.setValue(fact, forKey: "fact")
        story.setValue(urlStr, forKey: "urlString")
        do {
            try context.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    static func writeMetricToModel(entity: String, value: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entity, in: context)
        let metric = NSManagedObject(entity: entity!, insertInto: context)
        metric.setValue(value, forKey: "hasViewedAll")
        do {
            try context.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }

    }
    
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
    
    static func fetchObject(entity: String, title: String) -> NSManagedObject {
        var managedObject : NSManagedObject?
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchPredicate = NSPredicate(format: "title == %@", title)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = fetchPredicate
        
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            if !results.isEmpty {
                managedObject = results[0]
            }
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        return managedObject!
    }
    
    static func deleteObject(entity: String, title: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchPredicate = NSPredicate(format: "title == %@", title)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = fetchPredicate
        
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            for object in results {
             context.delete(object)
            }
            try context.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}
