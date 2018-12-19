//
//  OnboardingFlow.swift
//  Pwned
//
//  Created by Kevin on 10/25/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import UIKit
import RxFlow

class OnboardingFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }

    private let services: AppServices
    private let stepper: OnboardingStepper
    private let vcs: [UIViewController]
    private lazy var viewModel = {
        return OnboardingViewModel(dependencies: services)
    }()
    private lazy var rootViewController: OnboardingPageViewController = {
        let controller = OnboardingPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil)
        controller.viewModel = viewModel
        return controller
    }()

    private static func createVC(key: String, image: UIImage? = nil) -> OnboardingTemplateViewController {
        let controller = OnboardingTemplateViewController.instantiate()
        controller.image = image
        controller.text = NSLocalizedString(key, comment: "Content of the onboarding screen.")
        return controller
    }

    init(withServices services: AppServices, withStepper stepper: OnboardingStepper) {
        self.services = services
        self.stepper = stepper

        vcs = OnboardingViewModel.screens
            .map { (arg) -> OnboardingTemplateViewController in
                let (key, image) = arg
                return OnboardingFlow.createVC(key: key,
                                               image: UIImage(named: image))
            }
        rootViewController.vcs = vcs
    }

    func navigateToOnboarding() -> NextFlowItems {
        return navigateToOnboarding(page: 0)
    }

    func navigateToOnboarding(page: Int) -> NextFlowItems {
        let controller = vcs[page]
        rootViewController.setViewControllers([controller],
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(nextPresentable: rootViewController,
                         nextStepper: viewModel))
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.none }

        switch step {
        case .onboarding:
            return navigateToOnboarding()
        case .onboardingPage(let page):
            return navigateToOnboarding(page: page)
        case .onboardingCompleted:
            return .end(withStepForParentFlow: AppStep.dashboard)
        default:
            return NextFlowItems.none
        }
    }
}

class OnboardingStepper: Stepper {
    init() {
        self.step.accept(AppStep.onboarding)
    }
}
