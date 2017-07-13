//
//  AccessTokenAdapter.swift
//  alamofireTest
//
//  Created by Veronika Hristozova on 7/13/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import Alamofire

// Adapting and Retrying
class AccessTokenAdapter: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    
    private let sessionManager = SessionManager.default
    
    private var baseURLString: String
    private var accessToken: String
    private var refreshToken: String
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    init(baseURLString: String, accessToken: String, refreshToken: String) {
        self.baseURLString = baseURLString
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    
    // RequestAdapter method
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString){
            var urlRequest = urlRequest
            urlRequest.setValue("Bearer " + Preferences.accessToken , forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        return urlRequest
    }
    
    // RequestRetrier method
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.refreshToken = refreshToken
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        let urlString = "\(baseURLString)/account/token"
        
        let parameters: [String: Any] = [
            "username": "mmonova11@centroida.co",
            "password": "12345qQ",
            "verificationCode" : "",
            "grant_type": "password"
        ]
        
        sessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { [weak self] response in
            guard let strongSelf = self else { return }
            
            if
                let json = response.result.value as? [String: Any],
                let accessToken = json["refToken"] as? String,
                let refreshToken = json["refresh_token"] as? String
            {
                completion(true, accessToken, refreshToken)
            } else {
                completion(false, nil, nil)
            }
            
            strongSelf.isRefreshing = false
        }
    }
}


//primerno, or Keychain
struct Preferences {
    static var accessToken: String = ""
}
