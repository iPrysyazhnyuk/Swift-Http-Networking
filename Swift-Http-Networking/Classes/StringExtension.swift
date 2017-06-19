//
//  StringExtension.swift
//  Pods
//
//  Created by Igor Prysyazhnyuk on 6/16/17.
//
//

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}
