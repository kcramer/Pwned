//
//  BreachDetailViewModel.swift
//  Pwned
//
//  Created by Kevin on 7/9/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

struct BreachDetailViewModel: ViewModel {
    private let breach: Breach
    static let verifiedText = NSLocalizedString("Verified", comment: "Text for verified badge.")
    static let unverifiedText = NSLocalizedString("Unverified", comment: "Text for unverified badge.")
    static let fabricatedText = NSLocalizedString("Fabricated", comment: "Text for fabricated badge.")
    private static var countFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter
    }
    private static let htmlHeader = BreachDetailViewModel.getHTMLHeader(textColor: "#000")
    private static let htmlHeaderInverted = BreachDetailViewModel.getHTMLHeader(textColor: "#fff")
    private let htmlFooter: String = "</body></html>"

    var title: String {
        return breach.title
    }

    var breachDate: String {
        return breach.formattedDate
    }

    var pwnCount: String {
        return BreachDetailViewModel.countFormatter
            .string(from: NSNumber(value: breach.pwnCount)) ?? ""
    }

    var dataClasses: String {
        return breach.dataClasses.joined(separator: ", ")
    }

    var breachDescription: NSAttributedString {
        // Convert the HTML to an attributed string to display.
        let html = BreachDetailViewModel.htmlHeaderInverted +
            breach.descriptionText + htmlFooter
        guard let data = html.data(using: .utf8),
            let formatted = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil) else {
            return NSAttributedString(string: "")
        }
        return formatted
    }

    var verifiedStatus: String {
        return breach.isFabricated ? BreachDetailViewModel.fabricatedText :
            breach.isVerified ? BreachDetailViewModel.verifiedText :
                BreachDetailViewModel.unverifiedText
    }

    var verified: Bool {
        return breach.isVerified
    }

    init(breach: Breach) {
        self.breach = breach
    }

    private static func getHTMLHeader(textColor: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
        <style type=\"text/css\">
        body { font-family: -apple-system, HelveticaNeue, LucidaGrande;
        font-size: 17px; text-align: justify; color: \(textColor); }
        a { color: \(textColor); }
        table { border: 1px solid; font-size: 18px; border-collapse: collapse; }
        caption { padding-bottom: 5px; font-weight: bolder; }
        th { white-space: nowrap; vertical-align: text-top; border: 1px solid; }
        td { vertical-align: text-top; }
        table.striped tr:nth-child(even) { background-color: #eee; }
        table.striped tr:nth-child(odd) { background-color: #fff; }
        table.small-text { font-size: smaller }
        table.centered td { text-align: center; }
        table.caption { text-align: center; }
        dt, dt:after, dd { display: inline; }
        dd { margin: 0; }
        dd:after { content: ','; padding-right: .25em; }
        dl dd:last-child:after { content: '.'; }
        blockquote > p { margin-left: 15px; }
        </style>
        </head>
        <body>
        """
    }
}
