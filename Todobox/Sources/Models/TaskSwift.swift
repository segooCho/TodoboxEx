//
//  TaskSwift.swift
//  Todobox
//
//  Created by admin on 2017. 2. 15..
//  Copyright © 2017년 admin. All rights reserved.
//

import Foundation
import UIKit

struct Task {
    var title: String
    var detail: String
    var isDone: Bool
    
    init(title: String, detail: String, isDone: Bool = false) {
        self.title = title
        self.detail = detail
        self.isDone = isDone
    }
}


struct AlertButtonCancelYes {
    var sTitle: String
    var sMessage: String

    
    init(sTitle: String, sMessage: String) {
        self.sTitle = sTitle
        self.sMessage = sMessage
    }
}

