//
//  AccountCheckFlow.swift
//  Pwned
//
//  Created by Kevin on 7/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import RxFlow

class AccountsFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()
    private let services: AppServices
    private let stepper: AccountStepper

    init(withServices services: AppServices, andStepper stepper: AccountStepper) {
        self.services = services
        self.stepper = stepper
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.none }

        switch step {
        case .accountList:
            return navigateToAccountList()
        case .breachDetail(let breach):
            return navigateToBreachDetail(breach: breach)
        case .pasteDetail(let paste):
            return navigateToPasteDetail(paste: paste)
        case .visitURL(let url):
            return visit(url: url)
        default:
            return NextFlowItems.none
        }
    }

    func navigateToAccountList() -> NextFlowItems {
        let accountListModel = AccountListViewModel(dependencies: services)
        let accountListVC = AccountListViewController.instantiate(
            withViewModel: accountListModel)
        let historyModel = RecentSearchesViewModel(dependencies: services)
        let historyVC = RecentSearchesViewController.instantiate(
            withViewModel: historyModel)
        let viewController = AccountListWithHistoryViewController(
            accountList: accountListVC,
            history: historyVC,
            viewModel: accountListModel)
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.one(flowItem:
            NextFlowItem(nextPresentable: viewController,
                         nextStepper: accountListModel))
    }

    func navigateToBreachDetail(breach: Breach) -> NextFlowItems {
        let viewModel = BreachDetailViewModel(breach: breach)
        let viewController = BreachDetailViewController.instantiate(
            withViewModel: viewModel)
        viewController.title = viewModel.title
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.none
    }

    func navigateToPasteDetail(paste: Paste) -> NextFlowItems {
        let viewModel = PasteDetailViewModel(paste: paste)
        let viewController = PasteDetailViewController.instantiate(
            withViewModel: viewModel)
        viewController.title = viewModel.title
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.one(flowItem: NextFlowItem(
            nextPresentable: viewController, nextStepper: viewModel))
    }

    func visit(url: URL) -> NextFlowItems {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url,
                                      options: [:],
                                      completionHandler: nil)
        }
        return NextFlowItems.none
    }
}

class AccountStepper: Stepper {
    init() {
        self.step.accept(AppStep.accountList)
    }
}
