//
//  SearchHistory.swift
//  Pwned
//
//  Created by Kevin on 9/11/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import RxSwift

/// Provides an interface to get the account search history.
protocol HasSearchHistoryService {
    var searchHistoryService: SearchHistoryService { get }
}

/// Service that provides the account search history.
class SearchHistoryService {
    let mainStore: ReduxStore
    let settingsService: SettingsServiceProtocol

    private enum Constants {
        static let maxHistoryItems = 10
    }

    init(store: ReduxStore, settingsService: SettingsServiceProtocol) {
        mainStore = store
        self.settingsService = settingsService
        mainStore.dispatch(mutation: .setAccountHistory(getHistory()))
    }

    private func getHistory() -> [String] {
        return settingsService.accountHistory
    }

    private func setHistory(history: [String]) {
        settingsService.accountHistory = history
        mainStore.dispatch(mutation: .setAccountHistory(history))
    }

    func addToHistory(item: String) {
        // Get the history,
        // remove the item,
        // add it to the top of the history,
        // reduce the history to the top X items.
        let newHistory = getHistory()
            .filter { $0 != item }
            .prepend(item)
            .prefix(Constants.maxHistoryItems)
        setHistory(history: Array(newHistory))
    }

    func clearHistory() {
        setHistory(history: [])
    }
}

extension Array {
    func prepend(_ item: Element) -> [Element] {
        return [item] + self
    }
}
