//
//  PasswordCheckFlow.swift
//  Pwned
//
//  Created by Kevin on 7/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import RxFlow

class PasswordCheckFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()
    private let services: AppServices

    init(withServices services: AppServices) {
        self.services = services
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.none }

        switch step {
        case .passwordCheck:
            return navigateToPasswordCheck()
        default:
            return NextFlowItems.none
        }
    }

    func navigateToPasswordCheck() -> NextFlowItems {
        let formViewModel = PasswordFormViewModel(dependencies: services)
        let formVC = PasswordFormViewController.instantiate(
            withViewModel: formViewModel)
        let resultVC = PasswordResultViewController.instantiate(
            withViewModel: PasswordResultViewModel(dependencies: services))
        let viewController = PasswordViewController(
            form: formVC, result: resultVC, viewModel: formViewModel)
        viewController.title = NSLocalizedString(
            "Password Check", comment: "Title for password check screen.")
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.none
    }
}
