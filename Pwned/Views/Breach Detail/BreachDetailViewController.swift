//
//  BreachDetailViewController.swift
//  Pwned
//
//  Created by Kevin on 7/8/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import Reusable

class BreachDetailViewController: UIViewController, StoryboardBased, ViewModelBased {
    typealias ViewModelType = BreachDetailViewModel
    var viewModel: BreachDetailViewModel!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var breachDateLabel: UILabel!
    @IBOutlet weak var pwnCountLabel: UILabel!
    @IBOutlet weak var statusBadgeView: UIView!
    @IBOutlet weak var statusBadgeLabel: UILabel!
    @IBOutlet weak var dataClassesLabel: UILabel!

    private func configure() {
        titleLabel.text = viewModel.title
        breachDateLabel.text = viewModel.breachDate
        pwnCountLabel.text = viewModel.pwnCount
        statusBadgeLabel.text = viewModel.verifiedStatus
        statusBadgeView.backgroundColor = viewModel.verified ? .flatGreenDark : .flatRed
        dataClassesLabel.text = viewModel.dataClasses
        descriptionTextView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        DispatchQueue.global(qos: .userInitiated).async {
            let description = self.viewModel.breachDescription
            DispatchQueue.main.async {
                self.descriptionTextView.attributedText = description
                self.descriptionTextView.sizeToFit()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}
