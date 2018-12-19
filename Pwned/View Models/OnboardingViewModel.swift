//
//  OnboardingViewModel.swift
//  Pwned
//
//  Created by Kevin on 10/26/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import RxSwift
import RxFlow

class OnboardingViewModel: ViewModel {
    typealias Dependencies = HasSettingsService
    private let dependencies: Dependencies
    private let disposeBag = DisposeBag()

    // MARK: - Rx Inputs
    // Trigger skipping the onboarding.
    var skipTrigger = PublishSubject<Void>()
    // Trigger moving the a specific page.
    var nextTrigger = PublishSubject<Int?>()

    // The localization keys and image names for each
    // screen in the onboarding flow.
    static let screens = [
        ("OnboardingScreenOne", "HIBP Logo"),
        ("OnboardingScreenTwo", "Password Icon Wide"),
        ("OnboardingScreenThree", "Account List Icon")
    ]

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        // Inputs
        skipTrigger
            .subscribe(onNext: {
                self.onSkip()
            })
            .disposed(by: disposeBag)

        nextTrigger
            .subscribe(onNext: { page in
                if let page = page {
                    self.move(to: page)
                } else {
                    self.onComplete()
                }
            })
            .disposed(by: disposeBag)
    }

    func onSkip() {
        onComplete()
    }

    func onComplete() {
        dependencies.settingsService.onboardingCompleted = true
        done()
    }
}

extension OnboardingViewModel: Stepper {
    public func move(to page: Int) {
        self.step.accept(AppStep.onboardingPage(page))
    }

    public func done() {
        self.step.accept(AppStep.onboardingCompleted)
    }
}
