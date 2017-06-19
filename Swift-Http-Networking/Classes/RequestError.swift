//
//  RequestError.swift
//  Pods
//
//  Created by Igor Prysyazhnyuk on 6/16/17.
//
//

import Foundation

struct RequestError: Error, LocalizedError {
    let message: String
    
    var errorDescription: String? {
        return message
    }
}
