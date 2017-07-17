//
//  Request.swift
//  alamofireTest
//
//  Created by Veronika Hristozova on 6/30/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

enum APIRouter: URLRequestConvertible {
    case getBooks(Int, Int)
    case getBook(Int)
    case addBook(Book)
    case addPhoto(Data)
    
    static let baseURLString = "https://milenabooks.azurewebsites.net/api/"
    
    func asURLRequest() throws -> URLRequest {
        var method: HTTPMethod {
            switch self {
            case .getBooks, .getBook:
                return .get
            case .addBook:
                return .post
            case .addPhoto:
                return .post
            }
        }
        
        let params: ([String: Any]?) = {
            switch self {
            case .getBook:
                return nil
            case .addBook(let book):
                return (book.toJSON())
            case .addPhoto:
                return nil
            case .getBooks(let from, let to): return ["from": from, "to": to]
            }
        }()
        
        let url: URL = {
            let relativePath: String?
            switch self {
            case .getBooks, .addBook:
                relativePath = "books"
            case .getBook(let id):
                relativePath = "books/\(id)"
            case .addPhoto:
                relativePath = "upload"
            }
            
            var url = URL(string: APIRouter.baseURLString)!
            if let relativePath = relativePath {
                url = url.appendingPathComponent(relativePath)
            }
            return url
        }()
        
        
        var urlRequest = URLRequest(url: url)
        
        
        
        urlRequest.httpMethod = method.rawValue
        
        let encoding = JSONEncoding.default
        return try encoding.encode(urlRequest, with: params)
    }
}

extension APIRouter {
    
    
    //Session Manager
    static func getSessionManager() -> SessionManager {
    
        let oauthHandler = AccessTokenAdapter(baseURLString: "http://ec2-35-158-144-178.eu-central-1.compute.amazonaws.com/api", accessToken: "some access token", refreshToken: "some refresh token", email: "", password: "")
        
        let sessionManager = SessionManager()
        sessionManager.adapter = oauthHandler
        sessionManager.retrier = oauthHandler
        
       return sessionManager
    }
    
    // Get all books
    static func performGetBooks(from: Int, to: Int, completion: @escaping ([Book]) -> Void) {
        getSessionManager().request(APIRouter.getBooks(from, to)).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if let books = Mapper<Book>().mapArray(JSONObject: value) {
                    completion(books)
                }
            case .failure(let err):
                print(err.localizedDescription, response.request!.description)
            }
        }
    }
    
    // Get book by id
    static func performGetBook(id: Int, completion: @escaping (Book) -> Void) {
        getSessionManager().request(APIRouter.getBook(id)).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if let book = Book(JSON: value as! [String:Any]) {
                    completion(book)
                }
            case .failure(let err):
                print(err.localizedDescription, response.request!.description)
            }
        }
    }
    
    // Post new book
    static func performAddBook(book: Book, completion: @escaping (Bool) -> Void) {
        getSessionManager().request(APIRouter.addBook(book)).validate().responseJSON { response in
            switch response.result {
            case .success:
                completion(true)
            case .failure(let err):
                print(err.localizedDescription, response.request!.description)
                completion(false)
            }
        }
    }

    // Post photo(data)
    static func performChainOperations(photoJPG: Data, book: Book, completion: @escaping (Bool) -> Void) {
                getSessionManager().upload(multipartFormData: { multipartFormData in
            multipartFormData.append(photoJPG, withName: "fileset", fileName: "file.jpg", mimeType: "image/jpg")
        },
                         to: APIRouter.baseURLString + "upload")
        { result in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { progress in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    //TODO: check if this works
                    guard let json = response.result.value as? [String:Any] else { return }
                    print(json)
                    var book = book
                    book.pictureURL = json["URL"] as? String
                    //Chain:
                    self.performAddBook(book: book, completion: { success in
                        completion(success)
                    })
                }
                
            case .failure(let err):
                print(err.localizedDescription, "Upload request failed")
                completion(false)
            }
        }
    }
    
    //TODO: import PromiseKit
    func testChain() {
//        NSURLConnection.promise(
//            Alamofire.upload(...)
//            ).then { (request, response, data, error) in
//                self.performAddBook(book: book ...
//            }.then { (request, response, data, error) in
//                // Process data
//            }.then { _ in
//                // Reload table
//        }
    }
}


enum test: URLConvertible {
    func asURL() throws -> URL {
        return URL(string: "")!
    }
}

