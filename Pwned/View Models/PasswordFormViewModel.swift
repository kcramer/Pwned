//
//  PasswordFormViewModel.swift
//  Pwned
//
//  Created by Kevin on 11/4/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PasswordFormViewModel: ViewModel {
    typealias Dependencies = HasReduxStore & HasPwnedService
    private let dependencies: Dependencies
    private var mainStore: ReduxStore {
        return dependencies.mainStore
    }
    private let scheduler: SchedulerType
    private let searchScheduler: SchedulerType
    let placeholderText = NSLocalizedString("PasswordPlaceholder",
                                            comment: "Placeholder text for password field")
    let bag = DisposeBag()
    var password = BehaviorRelay<String>(value: "")

    lazy var resultsObservable: Observable<PasswordState> = {
        return mainStore
            .observable
            .map { $0.passwordResult }
            .distinctUntilChanged()
            .catchErrorJustReturn(.initialState)
            .share(replay: 1, scope: .whileConnected)
    }()

    lazy var isSearching: Observable<Bool> = {
        return resultsObservable
            .map { state -> Bool in
                guard case .searching = state else { return false }
                return true
            }
    }()

    init(dependencies: Dependencies,
         scheduler: SchedulerType = MainScheduler.instance,
         searchScheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInitiated)) {
        self.dependencies = dependencies
        self.scheduler = scheduler
        self.searchScheduler = searchScheduler
        password
            .observeOn(scheduler)
            .subscribe(onNext: { password in
                self.mainStore.dispatch(mutation: .passwordChanged(password))
                guard !password.isEmpty else {
                    self.mainStore.dispatch(mutation: .setPasswordResult(.initialState))
                    return
                }
                self.mainStore.dispatch(mutation: .setPasswordResult(.searching(password)))
            })
            .disposed(by: bag)

        resultsObservable
            .map { result -> String? in
                guard case .searching(let password) = result else { return nil }
                return password
            }
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest(search)
            .observeOn(scheduler)
            .subscribe(onNext: { result in
                self.mainStore.dispatch(mutation: .setPasswordResult(result))
            })
            .disposed(by: bag)
    }

    private func search(password: String) -> Observable<PasswordState> {
        return Observable.create({ observer in
            let request = self.dependencies.pwnedService
                .passwordByRange(password: password) { result in
                observer.onNext(.result(result))
                observer.onCompleted()
            }
            return Disposables.create {
                request?.cancel()
            }
        })
        .subscribeOn(searchScheduler)
    }
}
