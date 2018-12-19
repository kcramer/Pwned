//
//  Paste+Formatting.swift
//  Pwned
//
//  Created by Kevin on 11/10/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

extension Paste {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale.current
        return formatter
    }

    var formattedDate: String? {
        guard let date = date else { return nil }
        return Paste.dateFormatter.string(from: date)
    }

    var titleOrDefault: String {
        return title ?? NSLocalizedString(
            "Untitled", comment: "Default title when none is present.")
    }
}
