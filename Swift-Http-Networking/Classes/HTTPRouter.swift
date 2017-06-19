//
//  HTTPRouter.swift
//  Pods
//
//  Created by Igor Prysyazhnyuk on 6/16/17.
//
//

import Alamofire

public protocol HTTPRouter {
    var baseUrl: String { get }
    var endpoint: String { get }
    var url: String { get }
    var method: HTTPMethod { get }
    var params: Parameters? { get }
    var encoding: ParameterEncoding? { get }
    var headers: [String: String]? { get }
}

public extension HTTPRouter {
    var url: String { return baseUrl + endpoint }
    var params: Parameters? { return nil }
    var encoding: ParameterEncoding? { return nil }
    var headers: [String: String]? { return nil }
}
