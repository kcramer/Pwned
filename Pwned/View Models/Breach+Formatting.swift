//
//  Breach+Formatting.swift
//  Pwned
//
//  Created by Kevin on 11/10/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

extension Breach {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale.current
        return formatter
    }

    var formattedDate: String {
        return Breach.dateFormatter.string(from: breachDate)
    }
}
