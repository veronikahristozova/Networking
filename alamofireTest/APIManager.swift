//
//  APIManager.swift
//  alamofireTest
//
//  Created by Veronika Hristozova on 7/17/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import Foundation
import Alamofire


struct APIManager {
    public static let shared: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 5
        
        let manager = Alamofire.SessionManager(configuration: configuration)
        //Here some Preferences email and password properties
        let handler = AccessTokenAdapter(accessToken: "", refreshToken: "", email: "v@gmail.com", password: "123456")
        manager.adapter = handler
        manager.retrier = handler
        return manager
    }()
}
