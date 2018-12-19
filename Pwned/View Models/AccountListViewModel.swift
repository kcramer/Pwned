//
//  AccountListViewModel.swift
//  Pwned
//
//  Created by Kevin on 7/6/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

class AccountListViewModel: ViewModel {
    typealias Dependencies = HasReduxStore & HasPwnedService &
        HasSearchHistoryService & HasImageCacheService
    let dependencies: Dependencies
    private var mainStore: ReduxStore {
        return dependencies.mainStore
    }
    private let scheduler: SchedulerType
    private let requestScheduler: SchedulerType
    private let disposeBag = DisposeBag()

    // MARK: - Rx Inputs
    var account = BehaviorRelay<String>(value: "")
    var breachSelectedTrigger = PublishSubject<Breach>()
    var pasteSelectedTrigger = PublishSubject<Paste>()

    // MARK: - Rx Ouputs
    lazy var breachStateObservable: Observable<AccountState> = {
        return mainStore
            .observable
            .observeOn(scheduler)
            .map { $0.accountListResult }
            .catchErrorJustReturn(.initialState)
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)
    }()

    lazy var isSearching: Driver<Bool> = {
        return breachStateObservable
            .map { state in
                if case .searching = state {
                    return true
                } else {
                    return false
                }
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
    }()

    lazy var breachObservable: Driver<[AccountSection]> = {
        return breachStateObservable
            .map { state in
                switch state {
                case .initialState, .searching:
                    return []
                case .result(let result):
                    return self.convert(result: result)
                }
            }
            .asDriver(onErrorJustReturn: [])
    }()

    lazy var warningMessageObservable: Driver<String> = {
        return breachStateObservable
            .map({ state -> String in
                guard case .result(let result) = state else { return "" }
                switch result {
                case .notFound:
                    return NSLocalizedString(
                        "NoBreachesMsg",
                        comment: "Message displayed when no breaches are found.")
                case .failure(let errors):
                    let offline = errors.contains(where: { error -> Bool in
                        if case .offline = error {
                            return true
                        } else {
                            return false
                        }
                    })
                    let keyName = offline ?
                        "BreachSearchOfflineMsg" : "BreachSearchErrorMsg"
                    return NSLocalizedString(
                        keyName,
                        comment: "Message displayed when an error occurs.")
                case .success:
                    return ""
                }
            })
            .asDriver(onErrorJustReturn: "")
    }()

    private func bindInputs() {
        account
            .asObservable()
            .observeOn(scheduler)
            .subscribe(onNext: { account in
                self.mainStore.dispatch(mutation: .accountChanged(account))
            })
            .disposed(by: disposeBag)

        breachSelectedTrigger
            .subscribe(onNext: { [weak self] breach in
                self?.pick(breach: breach)
            })
            .disposed(by: disposeBag)

        pasteSelectedTrigger
            .subscribe(onNext: { [weak self] paste in
                self?.pick(paste: paste)
            })
            .disposed(by: disposeBag)
    }

    init(dependencies: Dependencies,
         scheduler: SchedulerType = MainScheduler.instance,
         requestScheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .userInitiated)) {
        self.dependencies = dependencies
        self.scheduler = scheduler
        self.requestScheduler = requestScheduler

        bindInputs()

        mainStore.observable
            .map { $0.accountText }
            .distinctUntilChanged()
            .observeOn(scheduler)
            .subscribe(onNext: { account in
                guard let account = account, !account.isEmpty else {
                    self.mainStore.dispatch(mutation: .setAccountListResult(.initialState))
                    return
                }
                self.mainStore.dispatch(mutation: .setAccountListResult(.searching(account)))
                self.dependencies.searchHistoryService.addToHistory(item: account)
            })
            .disposed(by: disposeBag)

        breachStateObservable
            .map { result -> String? in
                guard case .searching(let account) = result else { return nil }
                return account
            }
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { account in
                return Observable
                    .combineLatest(
                        self.fetchBreaches(for: account).startWith(nil),
                        self.fetchPastes(for: account).startWith(nil)
                    )
            }
            .map { (args) -> AccountListResult? in
                let (breach, paste) = args
                return AccountListResult(breach, paste)
            }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .map { $0! }
            .subscribe(onNext: { result in
                self.mainStore.dispatch(mutation: .setAccountListResult(.result(result)))
            })
            .disposed(by: disposeBag)
    }

    private func fetchBreaches(for account: String) -> Observable<BreachResult?> {
        return Observable.create({ observer -> Disposable in
            let request = self.dependencies.pwnedService.breaches(
                for: account,
                unverified: true) { result in
                    observer.onNext(result)
                    observer.onCompleted()
            }
            return Disposables.create {
                request?.cancel()
            }
        })
        .subscribeOn(requestScheduler)
    }

    private func fetchPastes(for account: String) -> Observable<PasteResult?> {
        guard PwnedService.isEmail(account) else {
            return Observable.from(optional: .notFound)
        }
        return Observable.create({ observer -> Disposable in
            let request = self.dependencies.pwnedService.pastes(for: account) { result in
                observer.onNext(result)
                observer.onCompleted()
            }
            return Disposables.create {
                request?.cancel()
            }
        })
        .subscribeOn(requestScheduler)
    }

    private func convert(result: AccountListResult) -> [AccountSection] {
        let breaches = result.breaches ?? []
        let pastes = result.pastes ?? []
        let breachHeader = String.localizedStringWithFormat(
            "Breaches (%d)", breaches.count)
        let pasteHeader = String.localizedStringWithFormat(
            "Pastes (%d)", pastes.count)
        return [
            AccountSection(model: breachHeader,
                items: breaches.map { return .breach($0) }),
            AccountSection(model: pasteHeader,
                items: pastes.map { return .paste($0) })
        ]
    }
}

extension AccountListViewModel: Stepper {
    public func pick(breach: Breach) {
        self.step.accept(AppStep.breachDetail(breach))
    }

    public func pick(paste: Paste) {
        self.step.accept(AppStep.pasteDetail(paste))
    }
}
