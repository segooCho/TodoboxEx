//
//  TaskEdit.swift
//  TodoboxEx
//
//  Created by admin on 2017. 7. 5..
//  Copyright © 2017년 admin. All rights reserved.
//

import Foundation

struct TaskEdit {
    var id: String
    
    init(id: String) {
        self.id = id
    }
    
    public func getTaskEditOid() -> String {
        return self.id
    }
}

/*
extension Notification.Name {
    static var postDidLike: Notification.Name { return .init("postDidLike") }
}
*/

