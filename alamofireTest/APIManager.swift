//
//  APIManager.swift
//  alamofireTest
//
//  Created by Veronika Hristozova on 7/17/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import Alamofire

struct APIManager {
    public static let shared: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 60
        
        let manager = Alamofire.SessionManager(configuration: configuration)
        
        let handler = AccessTokenAdapter() 
        manager.adapter = handler
        manager.retrier = handler
        return manager
    }()
}
