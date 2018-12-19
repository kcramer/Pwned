//
//  ReduxStore.swift
//  Pwned
//
//  Created by Kevin on 10/27/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFeedback

/// The object provides access to the app state.
protocol HasReduxStore {
    /// Returns the store with the app state.
    var mainStore: ReduxStore { get }
}

/// A simple Redux-style store.
class ReduxStore {
    private let disposeBag = DisposeBag()
    private let dispatchObservable: PublishSubject<Mutation>
    private let feedbackLoop: Observable<AppState>
    let observable = ReplaySubject<AppState>.create(bufferSize: 1)
    var state = AppState()

    init() {
        let dispatch = PublishSubject<Mutation>()
        feedbackLoop = Observable.system(
            initialState: self.state,
            reduce: AppState.reduce,
            scheduler: MainScheduler.instance,
            scheduledFeedback: { _ in return dispatch }
        )
        dispatchObservable = dispatch
        feedbackLoop
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.state = state
                self.observable.onNext(state)
            })
            .disposed(by: disposeBag)
    }

    /// Process a change to the app state.
    public func dispatch(mutation: Mutation) {
        dispatchObservable.onNext(mutation)
    }
}
