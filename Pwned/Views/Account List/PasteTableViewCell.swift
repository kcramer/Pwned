//
//  PasteTableViewCell.swift
//  Pwned
//
//  Created by Kevin on 11/7/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit

class PasteTableViewCell: UITableViewCell {
    var paste: Paste?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func configure(paste: Paste) {
        self.paste = paste
        titleLabel.text = paste.titleOrDefault
        dateLabel.text = paste.formattedDate
    }
}
