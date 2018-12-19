//
//  DashboardFlow.swift
//  Pwned
//
//  Created by Kevin on 7/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import RxFlow

class DashboardFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }

    let rootViewController = UITabBarController()
    private let services: AppServices

    init(withServices services: AppServices) {
        self.services = services
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.none }

        switch step {
        case .dashboard:
            return navigateToDashboard()
        default:
            return NextFlowItems.none
        }
    }

    private func navigateToDashboard() -> NextFlowItems {
        let accountStepper = AccountStepper()
        let accountFlow = AccountsFlow(withServices: self.services,
                                       andStepper: accountStepper)
        let passwordFlow = PasswordCheckFlow(withServices: self.services)

        Flows.whenReady(flow1: passwordFlow,
                        flow2: accountFlow,
                        block: { [unowned self] (root1: UINavigationController, root2: UINavigationController) in
            let passwordTitle = NSLocalizedString("Password",
                                                  comment: "Title for the password tab.")
            let accountTitle = NSLocalizedString("Account",
                                                 comment: "Title for the account tab.")
            let tabBarItem1 = UITabBarItem(title: passwordTitle,
                                           image: UIImage(named: "Lock Icon"),
                                           selectedImage: nil)
            let tabBarItem2 = UITabBarItem(title: accountTitle,
                                           image: UIImage(named: "Account Icon"),
                                           selectedImage: nil)
            root1.tabBarItem = tabBarItem1
            root1.title = passwordTitle
            root2.tabBarItem = tabBarItem2
            root2.title = accountTitle

            self.rootViewController.setViewControllers([root1, root2], animated: false)
        })

        return NextFlowItems.multiple(flowItems:
            [NextFlowItem(nextPresentable: passwordFlow,
                          nextStepper: OneStepper(withSingleStep: AppStep.passwordCheck)),
             NextFlowItem(nextPresentable: accountFlow,
                          nextStepper: accountStepper)])
    }
}
