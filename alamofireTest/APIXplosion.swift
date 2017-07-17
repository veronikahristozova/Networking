//
//  APIXplosion.swift
//  alamofireTest
//
//  Created by Veronika Hristozova on 7/13/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

enum APIxplosion: URLRequestConvertible {
    case getPlayers(Int, Int)
    
    static let baseURLString = "http://xplosion-backend-dev.herokuapp.com/api"
    
    func asURLRequest() throws -> URLRequest {
        var method: HTTPMethod {
            switch self {
            case .getPlayers:
                return .get
            }
        }
        
        let params: ([String: Any]?) = {
            switch self {
            case .getPlayers: return nil
            }
        }()
        
        let url: URL? = {
            let relativePath: String?
            let query: String?
            switch self {
            case .getPlayers(let from, let to):
                relativePath = "/players"
                query = "skip=\(from)&top=\(to)"
            }
            var urlComponents = URLComponents(string: APIxplosion.baseURLString)
            if let relativePath = relativePath {
                urlComponents?.path.append(relativePath)
                urlComponents?.query = query
            }
            guard let url = urlComponents?.url else { return nil }
            return url
        }()
        
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = method.rawValue
        let encoding = JSONEncoding.default
        return try encoding.encode(urlRequest, with: params)
    }
}

extension APIxplosion {
    
    // Get all books
    static func performGetPlayers(from: Int, to: Int, completion: @escaping ([Player]) -> Void) {
        
        APIManager.shared.request(APIxplosion.getPlayers(from, to)).validate().responseJSON { response in
            switch response.result {
            case .success(let value as [String:Any]):
                if let players = Mapper<Player>().mapArray(JSONObject: value["players"]) {
                    completion(players)
                }
            case .failure(let err):
                print(err.localizedDescription, response.request!.description)
            default: return
            }
        }
    }
}
