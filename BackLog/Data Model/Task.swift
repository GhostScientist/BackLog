//
//  Task.swift
//  BackLog
//
//  Created by Dakota Kim on 3/18/18.
//  Copyright © 2018 theghost. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var done: Bool = false
    @objc dynamic var title: String = ""
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "tasks")
}
