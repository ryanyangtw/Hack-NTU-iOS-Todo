//
//  TodoListsTableViewController.swift
//  Todo
//
//  Created by Ryan on 2015/4/15.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit
import CoreData

class TodoListsTableViewController: UITableViewController {
  
  var managedObjectContext: NSManagedObjectContext!
  
  // Live update the table view in response
  // make TodoListsTableViewController as the delefate for NDFetchedResultsController. Through this delefate, the view controller is informed that objects have been changed, added or deleted

  lazy var fetchedResultsController: NSFetchedResultsController = {
    let fetchRequest = NSFetchRequest()
    
    let entity = NSEntityDescription.entityForName("TodoItem", inManagedObjectContext: self.managedObjectContext)
    fetchRequest.entity = entity
    
    //let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    //fetchRequest.sortDescriptors = [sortDescriptor]
    let sortDescriptior = NSSortDescriptor(key: "name", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptior]

    
    // How many objects will be fetched at a time
    fetchRequest.fetchBatchSize = 20
    
    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "TodoItem")
    
    fetchedResultsController.delegate = self
    return fetchedResultsController
    }()
  
  // explicitly set the delegate to nil when you no longer need the NSFetcedResultsController, just so you don't get any more notifications that were still pending.
  // It's good to get into the habit of writing deinit methods
  deinit {
    fetchedResultsController.delegate = nil
  }


  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.leftBarButtonItem = editButtonItem()

    performFetch()
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  private func performFetch() {
    var error: NSError?
    if !fetchedResultsController.performFetch(&error) {
      fatalCoreDataError(error)
    }
  }
  
 
// Prepare For Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    
    if segue.identifier == "AddItem" {
      let controller = segue.destinationViewController as! ItemDetailViewController
      controller.managedObjectContext = managedObjectContext
      
    } else if segue.identifier == "EditItem" {
      let controller = segue.destinationViewController as! ItemDetailViewController
      
      controller.managedObjectContext = managedObjectContext
      
      if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
      
        let todoItem = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoItem
        controller.itemToEdit = todoItem
      }
      
    }
  }
  

// MARK: - TableView DataSource

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

      return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
    
    return sectionInfo.numberOfObjects
  }
  
  
  private struct Storyboard {
    static let CellReuseIdentifier = "ItemCell"
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
 
    
    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier) as! UITableViewCell
    
    let todoItem = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoItem
    
    cell.textLabel?.text = todoItem.name
    
    return cell
  }
  
  

  
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if editingStyle == .Delete {
      let todoItem = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoItem
      
      managedObjectContext.deleteObject(todoItem)
 
      var error: NSError?
      if !managedObjectContext.save(&error) {
        fatalCoreDataError(error)
      }
    }
  }


}




// MARK: - NSFetchedResultsController Delegate

// It doesn't matter where in the app you make these chenages, they can happen on any screen. When that screen saves the changes to the managed object context, the fetched results controller picks up on them right away.

extension TodoListsTableViewController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    
    println("*** controllerWillChangeContent")
    tableView.beginUpdates()
  }
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    
    switch type {
    
      case .Insert:
        println("*** NSFetchedResultsChangeInsert (object)")
        tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    
      case .Delete:
        println("*** NSFetchedResultsChangeDelete (object)")
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        
      case .Update:
        println("*** NSFetchedResultsChangeUpdate (object)")
        
        let cell = tableView.cellForRowAtIndexPath(indexPath!)
        let todoItem = controller.objectAtIndexPath(indexPath!) as! TodoItem
        
        cell?.textLabel?.text = todoItem.name
        
      case .Move:
        println("*** NSFetchResultsChangeMove (object)")
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      
    }
  }
  
  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    
    switch type {
    case .Insert:
      println("*** NSFetchedResultsChangeInsert (section)")
      tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
      
    case .Delete:
      println("*** NSFetchedResultsChangeDelete (section) ")
      tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
      
    case .Update:
      println("*** NSFetchedResultsChangeUpdate (section)")
      
    case .Move:
      println(" *** NSFethchedResultsChangeMove (section)")
    }
    
  }
  
  
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    println("*** controllerDidChangeContent")
    tableView.endUpdates()
  }

}
