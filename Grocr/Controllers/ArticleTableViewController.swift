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
    var articles: [Article] = []
    let ref = Database.database().reference(withPath: "article-list")
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

                print(self.user)
            })
        }
        
        self.ref.observe(.value) { (snapshot) in

            var newArticles: [Article] = []

            for child in snapshot.children {

                if let snapshot = child as? DataSnapshot,
                    let article = Article(snapShot: snapshot) {

                    newArticles.append(article)
                }
            }
            self.articles = newArticles
            self.tableView.reloadData()
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as? ArticleTableViewCell
            else { fatalError("Please Check Cell ID") }

        cell.title.text = self.articles[indexPath.row].title
        cell.content.text = self.articles[indexPath.row].content
        cell.author.text = self.articles[indexPath.row].author
        cell.date.text = self.articles[indexPath.row].createdDate

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 160
        
    }
    @IBAction func addButtonDidTouch(_ sender: Any) {

        let alert = UIAlertController(title: "Article", message: "Write an Article", preferredStyle: .alert)

        let writeAction = UIAlertAction(title: "Save", style: .default) { (_) in

            guard
                let titleTextField = alert.textFields?.first,
                let title = titleTextField.text,
                let contentTextField = alert.textFields?[1],
                let content = contentTextField.text else { return }

            let newArticle = Article(title: title,
                                     content: content,
                                     author: self.user.firstname
                                     )

            let articleRef = self.ref.child(title.lowercased())
            articleRef.setValue(newArticle.toAnyObject())
            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addTextField(configurationHandler: { (titleText) in
            titleText.placeholder = "title"
        })
        alert.addTextField(configurationHandler: { (contentText) in
            contentText.placeholder = "conttent"
        })

        alert.addAction(writeAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
