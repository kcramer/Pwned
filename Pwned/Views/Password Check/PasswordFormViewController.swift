//
//  PasswordFormViewController.swift
//  Pwned
//
//  Created by Kevin on 11/4/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import RxSwift
import RxFlow
import Reusable

class PasswordFormViewController: UIViewController, StoryboardBased, ViewModelBased {
    typealias ViewModelType = PasswordFormViewModel
    var viewModel: PasswordFormViewModel!
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
