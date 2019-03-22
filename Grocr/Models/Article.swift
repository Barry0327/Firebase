//
//  Article.swift
//  Grocr
//
//  Created by Chen Yi-Wei on 2019/3/21.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase

struct Article {

    let title: String
    let content: String
    let author: String
    let createdDate: String
    let ref: DatabaseReference?
    let key: String
    var whoLikedThis: [String] = ["uid"]

    init(title: String, content: String, author: String, date: Date = Date(), key: String = "") {

        self.title = title
        self.content = content
        self.author = author
        self.ref = nil

        let dateFormmater = DateFormatter()
        dateFormmater.dateFormat = "yyyy-M-dd HH:mm:ss"
        let timeStamp = dateFormmater.string(from: date)
        self.createdDate = timeStamp
        self.key = key
    }

    init?(snapShot: DataSnapshot){
        guard
            let value = snapShot.value as? [String: Any],
            let title = value["title"] as? String,
            let content = value["content"] as? String,
            let author = value["author"] as? String,
            let createdDate = value["createdDate"] as? String,
        let whoLikedThis = value["whoLikedThis"] as? [String]
            else { return nil }

        self.title = title
        self.content = content
        self.author = author
        self.createdDate = createdDate
        self.ref = snapShot.ref
        self.key = snapShot.key
        self.whoLikedThis = whoLikedThis

    }

    func toAnyObject() -> Any {
        return [
            "title": self.title,
            "content": self.content,
            "author": self.author,
            "createdDate": self.createdDate,
            "whoLikedThis": self.whoLikedThis
        ]
    }
}
