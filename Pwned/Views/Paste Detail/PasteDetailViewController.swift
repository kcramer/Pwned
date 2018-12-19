//
//  PasteDetailViewController.swift
//  Pwned
//
//  Created by Kevin on 11/10/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import Reusable
import RxSwift
import RxCocoa

class PasteDetailViewController: UIViewController, StoryboardBased, ViewModelBased {
    typealias ViewModelType = PasteDetailViewModel
    var viewModel: PasteDetailViewModel!
    private let disposeBag = DisposeBag()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var emailCountLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet var tapGesture: UITapGestureRecognizer!

    private func configure() {
        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.formattedDate
        emailCountLabel.text = viewModel.emailCount
        sourceLabel.text = viewModel.source
        urlLabel.text = viewModel.url
    }

    private func bindViewModel() {
        // Outputs
        tapGesture.rx
            .event
            .throttle(1.0, scheduler: MainScheduler.instance)
            .map { _ in }
            .bind(to: viewModel.visitURLTrigger)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bindViewModel()
    }
}
