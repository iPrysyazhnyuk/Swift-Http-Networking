//
//  ArrayPagerResponse.swift
//  Pods
//
//  Created by Igor Prysyazhnyuk on 6/16/17.
//
//

import ObjectMapper

struct ArrayPagerResponse<T: Mappable>: Mappable {
    var count: Int = 0
    var nextPage: String?
    var results: [T] = [T]()
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        count           <- map["count"]
        nextPage        <- map["next"]
        results         <- map["results"]
    }
}
