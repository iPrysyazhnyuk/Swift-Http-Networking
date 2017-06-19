//
//  Post.swift
//  Swift-Http-Networking
//
//  Created by Igor Prysyazhnyuk on 6/19/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import ObjectMapper

struct Post: Mappable {
    var id = 0
    var title = ""
    var body = ""
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id          <- map["id"]
        title       <- map["title"]
        body        <- map["body"]
    }
}
