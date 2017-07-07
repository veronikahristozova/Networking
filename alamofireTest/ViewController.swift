//
//  ViewController.swift
//  alamofireTest
//
//  Created by Veronika Hristozova on 6/30/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var books: [Book]?
    lazy var ApiProvider = APIProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBooks(from: 0, to: 30)
        
        //getBookById(id: 4)
        
        //let image = UIImage(named: "xplosion")
        //upload(photo: UIImageJPEGRepresentation(image!, 0.3)!)
        
        //addBook(book: books?.first)
    }
}
extension ViewController {
    func getBooks(from: Int, to: Int) {
        ApiProvider.performGetBooks(from: from, to: to) { books in
            print("\(books.count) books have been parsedddd")
            self.books = books
            //reload tableview etc
            //tableview.insertRows ...
        }
    }
    
    func getBookById(id: Int) {
        ApiProvider.performGetBook(id: id) { book in
            print(book)
        }
    }
    
    func addBook(book: Book) {
        ApiProvider.performAddBook(book: book) { success in
            if success {
                print("yas")
            }
        }
    }
    func upload(photo: Data) {
        guard let book = books?.first else { return }
        ApiProvider.performChainOperations(photoJPG: photo, book: book, completion: { success in
            if success {
                print("uploaded file")
            }
        })
    }
}
