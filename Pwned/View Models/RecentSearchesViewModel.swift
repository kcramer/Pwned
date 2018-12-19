//
//  RecentSearchesViewModel.swift
//  Pwned
//
//  Created by Kevin on 11/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

class RecentSearchesViewModel: ViewModel {
    typealias Dependencies = HasReduxStore & HasSearchHistoryService
    private let dependencies: Dependencies
    private var mainStore: ReduxStore {
        return dependencies.mainStore
    }
    private var historyService: SearchHistoryService {
        return dependencies.searchHistoryService
    }

    // MARK: - Rx Inputs
    /// Trigger when an account name is selected.
    var itemSelectedTrigger = PublishSubject<String>()

    let disposeBag = DisposeBag()

    // MARK: - Rx Output
    lazy var historyObservable: Observable<[HistorySection]> = {
        let recentTitle = NSLocalizedString("Recent",
                                            comment: "Title text for Recent Searches screen.")
        return mainStore
            .observable
            .map { $0.accountHistory }
            .distinctUntilChanged()
            .map { history in
                return !history.isEmpty ?
                    [HistorySection(model: recentTitle, items: history)] : []
            }
            .share(replay: 1, scope: .whileConnected)
    }()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        // Input
        itemSelectedTrigger
            .subscribe(onNext: { [weak self] account in
                self?.itemSelected(account: account)
            })
            .disposed(by: disposeBag)
    }

    func itemSelected(account: String) {
        mainStore.dispatch(mutation: .accountChanged(account))
    }

    func addToHistory(item: String) {
        historyService.addToHistory(item: item)
    }

    func clearHistory() {
        historyService.clearHistory()
    }
}
