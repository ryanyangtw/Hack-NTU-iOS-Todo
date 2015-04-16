//
//  ItemDetailViewController.swift
//  Todo
//
//  Created by Ryan on 2015/4/15.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailViewController: UIViewController {
  
  var managedObjectContext: NSManagedObjectContext!
  var name: String?
  
  var itemToEdit: TodoItem? {
    didSet {
      if let item = itemToEdit {
        name = item.name
      }
    }
  }
  


  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var actionButton: UIButton!
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      textField.text = name
      
      if itemToEdit != nil {
        actionButton.setTitle("Update", forState: .Normal)
      } else {
        actionButton.setTitle("Create", forState: .Normal)
      }
      
      // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

// MARK: IBAction

  @IBAction func done() {
    
    let hudView = HudView.hudInView(self.view, animated: true)
    var todoItem: TodoItem!
    
    if let temp = itemToEdit {
      hudView.text = "Updated"
      todoItem = temp
    } else {
      hudView.text = "Created"
      // 1 ask the NSEntityDescription class to insert a new object for your entity into the managed object context
      todoItem = NSEntityDescription.insertNewObjectForEntityForName("TodoItem", inManagedObjectContext: managedObjectContext) as! TodoItem
    }
    
    todoItem.name = textField.text
    

    
    var error: NSError?
    if !managedObjectContext.save(&error) {
      fatalCoreDataError(error)
    }
    
    
    // 返回上一頁
    afterDelay(0.6) {
      //self.dismissViewControllerAnimated(true, completion: nil)
      self.navigationController?.popViewControllerAnimated(true)
    }
    
    //dismissViewControllerAnimated(true, completion: nil)
    
  }
  
  
  
}
