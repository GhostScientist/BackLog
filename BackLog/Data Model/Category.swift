//
//  Category.swift
//  BackLog
//
//  Created by Dakota Kim on 3/18/18.
//  Copyright © 2018 theghost. All rights reserved.
//

import Foundation


class Category {
    var categoryName: String = ""
    var categoryColor: String = ""
    
    func returnDict() -> [String: Any] {
        var categoryDictionary: [String: Any] {
            return [
                "name": self.categoryName,
                "color": self.categoryColor
            ]
        }
        return categoryDictionary
    }
}
