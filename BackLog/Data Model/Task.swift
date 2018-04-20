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
    
    static func == (left: Task, right: Task) -> Bool {
        return left.title == right.title && left.dateCreated == right.dateCreated
    }
    
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
