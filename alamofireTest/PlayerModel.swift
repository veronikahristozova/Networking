//
//  PlayerModel.swift
//  alamofireTest
//
//  Created by Veronika Hristozova on 7/17/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import Foundation
import ObjectMapper

struct Player: Mappable {
    var id: String = ""
    var name: String = ""
    var age: Int = 1
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["_id"]
        name <- map["Name"]
        age <- map["Age"]
    }
}
