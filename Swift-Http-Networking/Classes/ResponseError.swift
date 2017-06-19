//
//  ResponseError.swift
//  Pods
//
//  Created by Igor Prysyazhnyuk on 6/19/17.
//
//

import ObjectMapper

struct ResponseError: Error, LocalizedError {
    let value: [String: Any]?
    let message: String?
    
    init(value: [String: Any]? = nil, message: String = "Unknown response error".localized) {
        self.value = value
        self.message = message
    }
    
    var errorDescription: String? {
        return message
    }
}

extension Error {
    public func parse<T: Mappable>() -> T? {
        guard let backendError = self as? ResponseError,
            let value = backendError.value else { return nil }
        return T(JSON: value)
    }
    
    public var possibleError: String {
        guard let backendError = self as? ResponseError,
            let value = backendError.value,
            let error = value.values.first as? String else { return localizedDescription }
        return error
    }
}
