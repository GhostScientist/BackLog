//
//  Task.swift
//  BackLog
//
//  Created by Dakota Kim on 3/18/18.
//  Copyright © 2018 theghost. All rights reserved.
//

import Foundation

class Task: Equatable {
    var done: Bool = false
    var title: String = ""
    var dateCreated : Date?
    var parentColor : String = ""
    var parent : String = ""
    
    // The == function is necessary to follow the Equatable protocol. This is to check
    // that two task objects are the same. If they have the same title and were created at the same
    // time, they are the same object. This is used in the TodoListViewController to remove Tasks
    // at index(of:). In order to use the index(of:) method, the object's class must follow the
    // Equatable protocol.
    
    static func == (left: Task, right: Task) -> Bool {
        return left.title == right.title && left.dateCreated == right.dateCreated
    }
    
    // The returnDict function returns a dictionary for a Task object for easy storage in Firestore.

    func returnDict() -> [String: Any] {
        var taskDictionary : [String: Any] {
            return [
                "done": self.done,
                "name": self.title,
                "parentColor": self.parentColor,
                "parent": self.parent,
                "dateCreated" : self.dateCreated
            ]
        }
        return taskDictionary
    }
}
