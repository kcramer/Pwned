//
//  AccountHistoryTableViewCell.swift
//  Pwned
//
//  Created by Kevin on 9/4/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit

class AccountHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(item: String) {
        titleLabel.text = item
    }
}
