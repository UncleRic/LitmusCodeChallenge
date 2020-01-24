//
//  ViewController.swift
//  LitmusCodeChallenge
//
//  Created by Frederick C. Lee on 9/13/18.
//  Copyright © 2018 Amourine Technologies. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!

    var books: [Item]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    var state = GoogleState() {
        didSet {
            guard let books = state.dataDict?.items else {
                return
            }

            if books.count > 0 {
                self.books = books
                collectionView.isHidden = false
                searchBar.resignFirstResponder()
                collectionView.reloadData()
            }
        }
    }

    func send(_ message: GoogleState.Message) {
        // Process the CurrencyState Command:
        if let command = state.process(message) {
            switch command {
            case let .loadData(url: url, message: transform): // ...make up a function name: 'transform'; a callback.
                URLSession.shared.dataTask(with: url) { data, _, error in
                    DispatchQueue.main.async { [weak self] in
                        if let msg = error?.localizedDescription {
                            let title = "Network Error"
                            let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                            let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(dismissAction)
                            self?.present(alertController, animated: true, completion: nil)
                        } else {
                            // ... use transform() to generate a message back to the state.
                            self?.send(transform(data)) // ...goes back to GoogleState.process() @ send() above.
                        }
                    }
                }.resume()

            case let .errorStatus(desc):
                let title = "Error"
                let msg = desc.error.info
                let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(dismissAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }

    private func downloadImageAtURL(_ url: URL, completion: @escaping (_ image: UIImage?, _ error: NSError?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            DispatchQueue.main.async { [weak self] in
                if let msg = error?.localizedDescription {
                    let title = "Network Error"
                    let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(dismissAction)
                    self?.present(alertController, animated: true, completion: nil)
                } else {
                    let myImage = UIImage(data: data!)
                    completion(myImage, nil)
                }
            }
        })
            .resume()
    }

    // ----------------------------------------------------------------------------------

    // MARK: - Action Methods

    @IBAction func tapGesture(_: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }

    @IBAction func exitAction(_: UIBarButtonItem) {
        exit(0)
    }
}

// ============================================================================================

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return books?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)

        if let book = books?[indexPath.item] {
            let imageLink = book.volumeInfo.imageLinks.smallThumbnail
            let title = book.volumeInfo.title
            let authors = book.volumeInfo.authors

            let url = URL(string: imageLink)
            downloadImageAtURL(url!, completion: { (image: UIImage?, error: NSError?) in
                if let myImage = image {
                    let imageView = cell.contentView.viewWithTag(1)! as! UIImageView
                    imageView.image = myImage

                    let titleLabel = cell.contentView.viewWithTag(2)! as! UILabel
                    let authorLabel = cell.contentView.viewWithTag(3)! as! UILabel

                    titleLabel.text = title
                    authorLabel.text = authors[0]

                    imageView.anchor(top: cell.contentView.safeAreaLayoutGuide.topAnchor,
                                     bottom: nil,
                                     left: cell.contentView.safeAreaLayoutGuide.leftAnchor,
                                     right: cell.contentView.safeAreaLayoutGuide.rightAnchor,
                                     centerYAnchor: nil,
                                     centerXAnchor: nil,
                                     paddingTop: 0,
                                     paddingLeft: 0,
                                     paddingBottom: 0,
                                     paddingRight: 0,
                                     width: 0,
                                     height: 62)

                    titleLabel.anchor(top: nil,
                                      bottom: cell.contentView.safeAreaLayoutGuide.bottomAnchor,
                                      left: cell.contentView.safeAreaLayoutGuide.leftAnchor,
                                      right: cell.contentView.safeAreaLayoutGuide.rightAnchor,
                                      centerYAnchor: nil,
                                      centerXAnchor: nil,
                                      paddingTop: 0,
                                      paddingLeft: 0,
                                      paddingBottom: -16.0,
                                      paddingRight: 0,
                                      width: 0,
                                      height: 16)

                    authorLabel.anchor(top: nil,
                                       bottom: cell.contentView.safeAreaLayoutGuide.bottomAnchor,
                                       left: cell.contentView.safeAreaLayoutGuide.leftAnchor,
                                       right: cell.contentView.safeAreaLayoutGuide.rightAnchor,
                                       centerYAnchor: nil,
                                       centerXAnchor: nil,
                                       paddingTop: 0,
                                       paddingLeft: 0,
                                       paddingBottom: 0.0,
                                       paddingRight: 0,
                                       width: 0,
                                       height: 18)

                } else if let myError = error {
                    print("*** ERROR in cell: \(myError.userInfo)")
                }
            }) // ...end completion.
        } else {
            let imagePlaceholder = UIImage(named: "ImagePlaceholder")
            let imageView = cell.contentView.viewWithTag(1)! as! UIImageView
            imageView.image = imagePlaceholder
        }
        return cell
    }
}

// ============================================================================================

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            send(.reload(searchBar.text!))
        }
    }

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 1 {
            books = nil
            state.dataDict = nil
            collectionView.isHidden = true
            collectionView.reloadData()
        }
    }
}
