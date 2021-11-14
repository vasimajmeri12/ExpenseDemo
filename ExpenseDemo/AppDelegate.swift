//
//  AppDelegate.swift
//  ExpenseDemo
//
//  Created by VASIM AJMERI on 14/11/21.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.addDefaultCategory()
        
        return true
    }
    
    //ADD DEFAULT CATEGORIES
    func addDefaultCategory(){
        if(Constants.getAppFirstLaunch()){ return }
        Constants.setAppFirstLaunch()
        let categoryEntity = NSEntityDescription.entity(forEntityName: Constants.ENTITY_NAME.CATEGORY.rawValue, in: Constants.MANAGED_CONTEXT)!
        var categoryID : Int16 = 1
        
        for category in Constants.arrCategory{
            let categoryObj  = NSManagedObject(entity: categoryEntity, insertInto: Constants.MANAGED_CONTEXT) as! Category
            categoryObj.id   = categoryID
            categoryObj.name = category
            categoryID += 1
        }

        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try Constants.MANAGED_CONTEXT.save()
           
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
   



    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ExpenseDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

