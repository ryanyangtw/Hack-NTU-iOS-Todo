//
//  AppDelegate.swift
//  Todo
//
//  Created by Ryan on 2015/4/15.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit
import CoreData

// define your own notifications
let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

// define a global function for handling fatal Core Data errors
func fatalCoreDataError(error: NSError?) {
  if let error = error {
    println("*** Fatal error: \(error), \(error.userInfo)")
  }
  
  // post Notifiaction
  NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: error)
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    
    let navigationController = window!.rootViewController as! UINavigationController
    
    if let tableViewController = navigationController.viewControllers?.first as? UITableViewController {
      
      let todoListsTableViewController = tableViewController as! TodoListsTableViewController
      
      todoListsTableViewController.managedObjectContext = managedObjectContext
    }
    
    // Register the NSNotificationCenter
    listenForFatalCoreDataNotifications()
    
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
// MARK: - Registered notification with NSNotificationCenter
  func listenForFatalCoreDataNotifications() {
    
    // Tell NSNotificationCenter that you want to be notified whenever a MyManagedObjectContextSaveDidFailNotification is posted
    NSNotificationCenter.defaultCenter().addObserverForName( MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
      
      // 2 Create a UIAlertController to show the error message
      let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .Alert)
      
      
      // 3
      let action = UIAlertAction(title: "OK", style: .Default) { _ in
        let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
        
        exception.raise()
      }
      
      alert.addAction(action)
      
      self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
    
    })
  
  }
  
  func viewControllerForShowingAlert() -> UIViewController {
  
    let rootViewController = self.window!.rootViewController!
    
    if let presentedViewController = rootViewController.presentedViewController {
      return presentedViewController
    } else {
      return rootViewController
    }
  }
  
  


// MARK: - Core Data
  
  // 1. NSMaanagedObjectContext: This is the object that you use to talk to Core Data (scratchpad)
  
  // 2. youd first make your change to the context and then you call its save() to store those changes permanently in the data store.
  
  // 3. Every object that needs to do something with Core Data needs to have a reference to the NSManagedObjectContext object.
  
  
  
  // This code creates a lazily loded instance variable named managedObjectContext
  lazy var managedObjectContext: NSManagedObjectContext = {
    
    // 1 Create an NSURL object pointing at this folder // Paths to filse and folders are often represented by URLs in the iOS framework
    if let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") {
      
      // 2 Create NSManagedObjectModel fromt the URL // his object represents the data model during runtime. In most apps you don't need to use the NSManagedObjectModel object directly
      if let model = NSManagedObjectModel(contentsOfURL: modelURL) {
        
        // 3 NSPersistentStoreCoordinator is in charge of the SQLite database
        let coordinator = NSPersistentStoreCoordinator( managedObjectModel: model)
        
        // 4 Create an NSURL object pointing at the DataStore.sqlite file
        // The app's data is stored in an SQLite database inside the app's Documents folder
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        let documentsDirectory = urls[0] as! NSURL
        let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
        
        println("\(storeURL)")
        
        // 5 Add the SQLite database to the store coordinator
        var error: NSError?
        
        if let store = coordinator.addPersistentStoreWithType( NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) {
          
          // 6 Create the NSManagedObjectContext object and return it
          let context = NSManagedObjectContext()
          context.persistentStoreCoordinator = coordinator
          return context
          
          // 7
        } else {
          println("Error adding persistent store at \(storeURL): \(error!) ")
        }
        
      } else {
        println("Error initializing model from: \(modelURL) ")
      }
      
    } else {
      println("Could not find data model in app bundle")
    }
    
    abort()
    
    }()
  
  
  


}

