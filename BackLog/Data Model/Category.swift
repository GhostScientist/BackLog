//
//  Category.swift
//  BackLog
//
//  Created by Dakota Kim on 3/18/18.
//  Copyright © 2018 theghost. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var categoryName: String = ""
    let tasks = List<Task>()
}
