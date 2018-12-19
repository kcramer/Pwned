//
//  AppState.swift
//  Pwned
//
//  Created by Kevin on 10/24/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import os.log

/// The combined state of the app.
struct AppState {
    // Onboarding
    /// Has the user completed the onboarding?
    var onboardingCompleted: Bool = false

    // Password Screen
    /// The result of a password search.
    var passwordResult: PasswordState = .initialState
    /// The text in the password field.
    var passwordText: String?

    // AccountList Screen
    /// The result of a breach search.
    var accountListResult: AccountState = .initialState
    /// The text in the account field.
    var accountText: String?
    /// The recent searches.
    var accountHistory: [String] = []

    // BreachDetail screen
    /// The current breach item to display.
    var breachDetail: Breach?

    // Marge changes into the existing state and return the new state.
    static func reduce(state: AppState, mutation: Mutation) -> AppState {
        os_log("Mutation: %@",
               log: AppDelegate.logger,
               type: .debug,
               String(describing: mutation))
        var newState = state
        switch mutation {
        case .setOnboardingStatus(let status):
            newState.onboardingCompleted = status
        case .passwordChanged(let password):
            newState.passwordText = password
        case .setPasswordResult(let result):
            newState.passwordResult = result
        case .setAccountListResult(let result):
            newState.accountListResult = result
        case .accountChanged(let account):
            newState.accountText = account
        case .setAccountHistory(let searches):
            newState.accountHistory = searches
        case .setBreachDetail(let breach):
            newState.breachDetail = breach
        }
        return newState
    }
}

enum Mutation: CustomStringConvertible {
    case setOnboardingStatus(Bool)
    case passwordChanged(String)
    case setPasswordResult(PasswordState)
    case setAccountListResult(AccountState)
    case accountChanged(String)
    case setAccountHistory([String])
    case setBreachDetail(Breach)

    var description: String {
        switch self {
        case .setOnboardingStatus(let status):
            return "setOnboardingStatus(\(status))"
        case .passwordChanged(let password):
            return "passwordChanged(\(password.isEmpty ? "" : "..."))"
        case .setPasswordResult(let state):
            return "setPasswordResult(\(state))"
        case .setAccountListResult(let state):
            return "setBreachResult(\(state))"
        case .accountChanged(let account):
            return "accountChanged(\(account))"
        case .setAccountHistory(let searches):
            return "setAccountHistory(\(searches))"
        case .setBreachDetail(let breach):
            return "setBreachDetail(\(breach))"
        }
    }
}
