//
//  TaskList.swift
//  TodoboxEx
//
//  Created by admin on 2017. 6. 28..
//  Copyright © 2017년 admin. All rights reserved.
//


import ObjectMapper

struct TaskList: Mappable {
    
    var id: String!         //! 값이 항상 있다.
    var fromUser: String!   //! 값이 항상 있다.
    var nickName: String!   //! 값이 항상 있다.
    var phoneNo: String!    //! 값이 항상 있다.
    var message: String?    //? 값이 항상 있지 않을 수도 있다.
    //var isDone: Bool!     //! 값이 항상 있다.
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["_id"]
        self.fromUser <- map["fromUser"]
        self.nickName <- map["nickName"]
        self.phoneNo <- map["phoneNo"]
        self.message <- map["message"]
        //self.title <- map["user.username"]
        //self.detail <- map["message"]
        ////self.isDone <- map["is_liked"]
    }
}
