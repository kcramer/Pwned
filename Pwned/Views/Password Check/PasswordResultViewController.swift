//
//  PasswordResultViewController.swift
//  Pwned
//
//  Created by Kevin on 11/4/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import RxSwift
import RxFlow
import Reusable

class PasswordResultViewController: UIViewController, StoryboardBased, ViewModelBased {
    typealias ViewModelType = PasswordResultViewModel
    var viewModel: PasswordResultViewModel!

    private let disposeBag = DisposeBag()

    private struct Colors {
        static let red = UIColor(displayP3Red: 220/255.0,
                                 green: 2/255.0,
                                 blue: 27/2555.0, alpha: 1.0)
        static let green = UIColor(displayP3Red: 38/255.0,
                                   green: 164/255.0,
                                   blue: 36/2555.0, alpha: 1.0)

        static func getColor(for option: PasswordResultViewState.Color) -> UIColor {
            switch option {
            case .green:
                return .green
            case .red:
                return .red
            }
        }
    }

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var occurrencesLabel: UILabel!

    private func bindViewModel() {
        // Inputs
        viewModel
            .viewStateObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.update(state: state)
            })
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        countLabel.textColor = Colors.red
    }

    private func update(state: PasswordResultViewState) {
        resultImageView.image = UIImage(named: state.imageName)
        countLabel.textColor = Colors.getColor(for: state.countColor)
        countLabel.text = state.countText
        occurrencesLabel.isHidden = !state.showOccurrences
    }
}
