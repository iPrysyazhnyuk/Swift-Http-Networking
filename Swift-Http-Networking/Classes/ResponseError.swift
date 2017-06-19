//
//  ResponseError.swift
//  Pods
//
//  Created by Igor Prysyazhnyuk on 6/19/17.
//
//

import ObjectMapper

struct ResponseError: Error, LocalizedError {
    let value: [String: Any]
    
    var errorDescription: String? {
        return "Unknown response error".localized
    }
}

extension Error {
    public func parse<T: Mappable>() -> T? {
        guard let backendError = self as? ResponseError else { return nil }
        return T(JSON: backendError.value)
    }
    
    public var possibleError: String {
        guard let backendError = self as? ResponseError,
            let error = backendError.value.values.first as? String else { return localizedDescription }
        return error
    }
}
