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
    let articleListDB = Database.database().reference(withPath: "article-list")
    let userListRef = Database.database().reference(withPath: "users")


    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let logOutButton = UIBarButtonItem(title: "Sign out",
                                           style: .plain,
                                           target: self,
                                           action: #selector(signOutDidTouch))

        logOutButton.tintColor = .white
        
        self.navigationItem.leftBarButtonItem = logOutButton

        tableView.allowsMultipleSelectionDuringEditing = false

        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")


        Auth.auth().addStateDidChangeListener { (auth, user) in

            guard let user = user else { return }
            self.user = User.init(authData: user)

            let currentUserRef = self.userListRef.child(self.user.uid)

            currentUserRef.observe(.value, with: { (snapshot) in

                guard
                    let info = snapshot.value as? [String: Any],
                    let firstname: String = info["firstname"] as? String,
                    let lastname: String = info["lastname"] as? String

                else { return }


                self.user.firstname = firstname
                self.user.lastname = lastname

                print(self.user)
            })
        }
        
        self.articleListDB.observe(.value) { (snapshot) in

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
        cell.likeButton.addTarget(self, action: #selector(likeDidPressed), for: .touchUpInside)

        // Check if user is already liked the article

        for uid in articles[indexPath.row].whoLikedThis {
            if uid == self.user.uid {
                cell.likeButton.tintColor = .red
            }
        }

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
                                     author: "\(self.user.firstname) \(self.user.lastname)"
                                     )

            let newAricleDB = self.articleListDB.childByAutoId()
            newAricleDB.setValue(newArticle.toAnyObject())
            self.user.createdArticles.append(newAricleDB.key)
            let currentUserRef = self.userListRef.child(self.user.uid)
            currentUserRef.child("createdArticles").setValue(self.user.createdArticles)

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

    @objc func signOutDidTouch() {

        if Auth.auth().currentUser != nil {

            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    @objc func likeDidPressed(_ sender: UIButton) {

        guard
            let cell = sender.superview?.superview as? ArticleTableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let currentUserUID = Auth.auth().currentUser?.uid
            else { fatalError("Failed to get the cell from like button")}

        var article = self.articles[indexPath.row]
        let articleLikedDB = self.articleListDB.child(article.key).child("whoLikedThis")
        let currentUserRef = self.userListRef.child(self.user.uid)

        if cell.likeButton.tintColor == .gray {

            cell.likeButton.tintColor = .red

            article.whoLikedThis.append(currentUserUID)
            articleLikedDB.setValue(article.whoLikedThis)
            self.user.likedArticleID.append(article.key)
            currentUserRef.child("likedArticleID").setValue(self.user.likedArticleID)

        } else {

            cell.likeButton.tintColor = .gray
            let newArray = article.whoLikedThis.filter { $0 != currentUserUID}
            articleLikedDB.setValue(newArray)
            self.user.likedArticleID = self.user.likedArticleID.filter {$0 != article.key}
            currentUserRef.child("likedArticleID").setValue(self.user.likedArticleID)

        }
    }
}
