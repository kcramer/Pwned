//
//  AppStep.swift
//  Pwned
//
//  Created by Kevin on 7/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import RxFlow

enum AppStep: Step {
    case onboarding
    case onboardingPage(Int)
    case onboardingCompleted
    case dashboard

    case passwordCheck
    case accountList
    case breachDetail(Breach)
    case pasteDetail(Paste)
    case visitURL(URL)
}
