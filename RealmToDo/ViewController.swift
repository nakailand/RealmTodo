//
//  ViewController.swift
//  RealmToDo
//
//  Created by nakazy on 2015/05/07.
//  Copyright (c) 2015年 nakazy. All rights reserved.
//

import UIKit

class ToDoItem: RLMObject {
    dynamic var name = ""
    dynamic var finished = false
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddViewControllerDelegate {
    private var tableView: UITableView!

    var todos: RLMResults {
        get {
            let predicate = NSPredicate(format: "finished == false", argumentArray: nil)
            return ToDoItem.objectsWithPredicate(predicate)
        }
    }
    
    var finished: RLMResults {
        get {
            let predicate = NSPredicate(format: "finished == true", argumentArray: nil)
            return ToDoItem.objectsWithPredicate(predicate)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonAction")
    }
    
    func addButtonAction() {
        let addViewController = AddViewController(nibName: nil, bundle: nil)
        addViewController.delegate = self
        let navController = UINavigationController(rootViewController: addViewController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Int(todos.count)
        case 1:
            return Int(finished.count)
        default:
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "To do"
        case 1:
            return "Finished"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath) as! UITableViewCell
        
        switch indexPath.section {
        case 0:
            let todoItem = todos.objectAtIndex(UInt(indexPath.row)) as! ToDoItem
            var attributedText = NSMutableAttributedString(string: todoItem.name)
            attributedText.addAttribute(NSStrikethroughStyleAttributeName, value: 0, range: NSMakeRange(0, attributedText.length))
            cell.textLabel!.attributedText = attributedText
        case 1:
            let todoItem = finished.objectAtIndex(UInt(indexPath.row)) as! ToDoItem
            var attributedText = NSMutableAttributedString(string: todoItem.name)
            attributedText.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributedText.length))
            cell.textLabel!.attributedText = attributedText
        default:
            break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var todoItem: ToDoItem?
        
        switch indexPath.section {
        case 0:
            todoItem = todos.objectAtIndex(UInt(indexPath.row)) as? ToDoItem
        case 1:
            todoItem = finished.objectAtIndex(UInt(indexPath.row)) as? ToDoItem
        default:
            break
        }
        
        // todoとdoneのトグル
        let realm = RLMRealm.defaultRealm()
        realm.transactionWithBlock() {
            todoItem?.finished = !todoItem!.finished
        }
        
        // テーブルの更新処理
        tableView.reloadData()
    }
    
    func didFinishTypingText(typedText: String?) {
        if typedText != "" {
            
            let newTodoItem = ToDoItem()
            newTodoItem.name = typedText!
            
            let realm = RLMRealm.defaultRealm()
            realm.transactionWithBlock() {
                realm.addObject(newTodoItem)
            }
            
            // テーブルの更新処理
            tableView.reloadData()
        }
    }
}

