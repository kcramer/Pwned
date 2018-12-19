//
//  SettingsService.swift
//  Pwned
//
//  Created by Kevin on 10/27/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

protocol HasSettingsService {
    var settingsService: SettingsServiceProtocol { get }
}

/// Provides an interface to get and set user settings.
protocol SettingsServiceProtocol: class {
    /// Whether the user has completed onboarding.
    var onboardingCompleted: Bool { get set }
    /// The user's account search history.
    var accountHistory: [String] { get set }
    /// Should the onboarding status be reset?
    var resetOnboarding: Bool { get set }
    /// Should the image cache be cleared?
    var clearImageCache: Bool { get set }
}

/// A service to get and set user settings from UserDefaults.
class SettingsService: SettingsServiceProtocol {
    let mainStore: ReduxStore

    private enum DefaultKey: String, RawRepresentable {
        case accountHistory
        case onboardingCompleted
        case resetOnboarding
        case clearImageCache
    }

    /// Whether the user has completed onboarding.
    var accountHistory: [String] {
        get {
            return get(forKey: .accountHistory) ?? []
        }

        set {
            set(newValue, forKey: .accountHistory)
        }
    }

    /// The user's account search history.
    var onboardingCompleted: Bool {
        get {
            return get(forKey: .onboardingCompleted) ?? false
        }

        set {
            set(newValue, forKey: .onboardingCompleted)
            mainStore.dispatch(mutation: .setOnboardingStatus(newValue))
        }
    }

    /// Should the onboarding status be reset?
    var resetOnboarding: Bool {
        get {
            return get(forKey: .resetOnboarding) ?? false
        }

        set {
            set(newValue, forKey: .resetOnboarding)
        }
    }

    /// Should the image cache be cleared?
    var clearImageCache: Bool {
        get {
            return get(forKey: .clearImageCache) ?? false
        }

        set {
            set(newValue, forKey: .clearImageCache)
        }
    }

    init(store: ReduxStore) {
        mainStore = store
        if resetOnboarding {
            onboardingCompleted = false
            resetOnboarding = false
        }
        mainStore.dispatch(mutation: .setOnboardingStatus(onboardingCompleted))
    }
}

// Helper methods for UserDefaults
extension SettingsService {
    private func get<T>(forKey key: DefaultKey) -> T? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key.rawValue) as? T
    }

    private func set<T>(_ value: T, forKey key: DefaultKey) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key.rawValue)
        defaults.synchronize()
    }
}
