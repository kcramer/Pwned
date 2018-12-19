//
//  Breach+Description.swift
//  Pwned
//
//  Created by Kevin on 12/18/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

// Provide a custom description that limits string length since the
// description field of a breach can possibly be thousands of characters.
// It makes the console debug output easier to read.
extension Breach: CustomStringConvertible {
    public var description: String {
        let name = String(describing: type(of: self))
        let mirror = Mirror(reflecting: self)
        let properties = mirror.children
            .compactMap { child -> String? in
                guard let name = child.label else { return nil }
                if child.value is String {
                    return "\(name): \"\(String(describing: child.value).prefix(100))\""
                } else {
                    return "\(name): \(String(describing: child.value))"
                }
            }
            .joined(separator: ", ")
        return "\(name)(\(properties))"
    }
}
