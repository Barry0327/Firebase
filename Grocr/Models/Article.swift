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
//    let date: Date

    init(title: String, content: String, author: String) {

        self.title = title
        self.content = content
        self.author = author
    }

    init?(snapShot: DataSnapshot){
        guard
            let value = snapShot.value as? [String: Any],
            let title = value["title"] as? String,
            let content = value["content"] as? String,
            let author = value["author"] as? String
            else { return nil }

        self.title = title
        self.content = content
        self.author = author

    }

    func toAnyObject() -> Any {
        return [
            "title": self.title,
            "content": self.content,
            "author": self.author
        ]
    }
}
