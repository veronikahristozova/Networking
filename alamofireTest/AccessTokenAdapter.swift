//
//  AccessTokenAdapter.swift
//  alamofireTest
//
//  Created by Veronika Hristozova on 7/13/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import Alamofire
//MAJOR TODO: beautify this!!!

// Adapting and Retrying
class AccessTokenAdapter: RequestAdapter, RequestRetrier {
    
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    private var defaultRetryCount = 4
    
    // RequestAdapter method
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue("Bearer " + Preferences.accessToken , forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    // RequestRetrier method
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    if let accessToken = accessToken {
                        Preferences.accessToken = accessToken
                        //strongSelf.refreshToken = refreshToken
                        _ = try? strongSelf.adapt(request.request!)
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else if (error as NSError).code == -1001  { //Timeout status code
            print(error)
            if defaultRetryCount == 0 {
                completion(false, 0)
            } else {
                defaultRetryCount = defaultRetryCount - 1
                completion(true, 4)
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        isRefreshing = true
        
        //The url for the token
        let urlString = "\(APIxplosion.baseURLString)/login"
        
        //Needed params for authentication
        let parameters: [String: Any] = [
            "Email": Preferences.email,
            "Password": Preferences.password,
        ]
        
        //The request for new token
        APIManager.shared.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { [weak self] response in
            guard let strongSelf = self else { return }
            
            if let json = response.result.value as? [String: Any], let accessToken = json["token"] as? String {
                completion(true, accessToken, nil)
            } else {
                completion(false, nil, nil)
            }
            
            strongSelf.isRefreshing = false
        }
    }
}
