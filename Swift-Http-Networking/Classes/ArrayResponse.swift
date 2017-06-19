//
//  ArrayResponse.swift
//  Pods
//
//  Created by Igor Prysyazhnyuk on 6/19/17.
//
//

import ObjectMapper

public struct ArrayResponse<T: Mappable>: Mappable {
    public var array = [T]()
    
    public init?(map: Map) {
        mapping(map: map)
    }
    
    mutating public func mapping(map: Map) {
        array       <- map[HTTPRequest.Key.array.rawValue]
    }
}
