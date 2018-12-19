//
//  AppFlow.swift
//  Pwned
//
//  Created by Kevin on 7/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import RxFlow

class AppFlow: Flow {
    var root: Presentable {
        return self.rootWindow
    }

    private let rootWindow: UIWindow
    private let services: AppServices

    init(withWindow window: UIWindow, andServices services: AppServices) {
        self.rootWindow = window
        self.services = services
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.none }

        switch step {
        case .dashboard:
            return navigationToDashboardScreen()
        case .onboarding:
            return navigationToOnboardingScreen()
        default:
            return NextFlowItems.none
        }
    }

    private func navigationToOnboardingScreen () -> NextFlowItems {
        let onboardingFlow = OnboardingFlow(withServices: self.services,
                                            withStepper: OnboardingStepper())
        Flows.whenReady(flow1: onboardingFlow) { [unowned self] (root) in
            self.rootWindow.rootViewController = root
        }
        return NextFlowItems.one(
            flowItem: NextFlowItem(nextPresentable: onboardingFlow,
                                   nextStepper: OneStepper(withSingleStep: AppStep.onboarding)))
    }

    private func navigationToDashboardScreen () -> NextFlowItems {
        let dashboardFlow = DashboardFlow(withServices: self.services)
        Flows.whenReady(flow1: dashboardFlow) { [unowned self] (root) in
            self.rootWindow.rootViewController = root
        }
        return NextFlowItems.one(
            flowItem: NextFlowItem(nextPresentable: dashboardFlow,
                                   nextStepper: OneStepper(withSingleStep: AppStep.dashboard)))
    }
}

class AppStepper: Stepper {
    init(withServices services: AppServices) {
        if !services.settingsService.onboardingCompleted {
            self.step.accept(AppStep.onboarding)
        } else {
            self.step.accept(AppStep.dashboard)
        }
    }
}
