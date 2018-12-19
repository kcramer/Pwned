//
//  AccountHistoryHeaderTableViewCell.swift
//  Pwned
//
//  Created by Kevin on 9/11/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit

class AccountHistoryHeaderTableViewCell: UITableViewCell {
    var viewModel: RecentSearchesViewModel?

    @IBOutlet weak var titleLabel: UILabel!

    @IBAction func clearButton(_ sender: UIButton) {
        viewModel?.clearHistory()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(title: String, model: RecentSearchesViewModel) {
        titleLabel.text = title
        viewModel = model
    }
}
