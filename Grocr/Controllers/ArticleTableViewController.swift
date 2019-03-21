//
//  ArticleTableViewController.swift
//  Grocr
//
//  Created by Chen Yi-Wei on 2019/3/21.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase

class ArticleTableViewController: UITableViewController {

    var user: User!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsMultipleSelectionDuringEditing = false

        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")


        Auth.auth().addStateDidChangeListener { (auth, user) in

            guard let user = user else { return }
            self.user = User.init(authData: user)

            let userListRef = Database.database().reference(withPath: "users")
            let currentUserRef = userListRef.child(self.user.uid)
            currentUserRef.observe(.value, with: { (snapshot) in

                guard let info = snapshot.value as? [String: String] else { return }
                let firstname = info["firstname"] ?? ""
                let lastname = info["lastname"] ?? ""

                self.user.firstname = firstname
                self.user.lastname = lastname
            })
        }
        
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as? ArticleTableViewCell
            else { fatalError("Please Check Cell ID") }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 160
        
    }
}
