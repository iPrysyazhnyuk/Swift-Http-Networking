//
//  JSONPlaceholderRouter.swift
//  Swift-Http-Networking
//
//  Created by Igor Prysyazhnyuk on 6/19/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Swift_Http_Networking
import Alamofire

enum JSONPlaceholderRouter: HTTPRouter {
    
    case posts
    case post(id: Int)
    
    var baseUrl: String { return "https://jsonplaceholder.typicode.com/" }
    
    var endpoint: String {
        switch self {
        case .posts: return "posts"
        case .post(let id): return "posts/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .posts,
             .post: return .get
        }
    }
}
