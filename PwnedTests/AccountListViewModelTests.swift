//
//  AccountListViewModelTests.swift
//  PwnedTests
//
//  Created by Kevin on 11/16/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import Pwned

class AccountListViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Given an event that updates the account to search on,
    // verify that the search state, isSearching, and history observables
    // emit the correct values.
    private func check(account: String,
                       accountResult: [AccountState],
                       isSearching: [Bool],
                       history: [[String]]) {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let dependencies = createServices()
        let viewModel = AccountListViewModel(dependencies: dependencies,
                                             scheduler: scheduler,
                                             requestScheduler: scheduler)
        let historyViewModel = RecentSearchesViewModel(dependencies: dependencies)
        let stateObs = scheduler.createObserver(AccountState.self)
        let isSearchingObs = scheduler.createObserver(Bool.self)
        let historyObs = scheduler.createObserver([String].self)

        viewModel.breachStateObservable
            .asDriver(onErrorJustReturn: .initialState)
            .drive(stateObs)
            .disposed(by: disposeBag)

        viewModel.isSearching
            .drive(isSearchingObs)
            .disposed(by: disposeBag)

        // Extract the actual history from the section to verify its values.
        historyViewModel.historyObservable
            .map { $0.first?.items ?? [] }
            .asDriver(onErrorJustReturn: [])
            .drive(historyObs)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([
                .next(10, account)
            ])
            .bind(to: viewModel.account)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(
            stateObs.events.map { $0.value.element },
            accountResult,
            "resultsObservable must emit the correct events!")

        XCTAssertEqual(
            isSearchingObs.events.map { $0.value.element },
            isSearching,
            "isSearching must emit the correct events!")

        XCTAssertEqual(
            historyObs.events.map { $0.value.element },
            history,
            "historyObservable must emit the correct events!")
    }

    func testFound() {
        let account = "john.doe@example.com"
        check(account: account,
              accountResult: [
                .initialState,
                .searching(account),
                .result(.success(johnDoeBreachParsed, nil)),
                .result(.success(johnDoeBreachParsed, johnDoePastesParsed))
                ],
              isSearching: [
                false,
                true,
                false
                ],
              history: [
                [],
                [account]
            ])
    }

    func testNotFound() {
        let account = "noone@nowhere.com"
        check(account: account,
              accountResult: [
                .initialState,
                .searching(account),
                .result(.notFound)
                ],
              isSearching: [
                false,
                true,
                false
                ],
              history: [
                [],
                [account]
            ])
    }

    func testErrorWithEmail() {
        let account = "error@nowhere.com"
        check(account: account,
              accountResult: [
                .initialState,
                .searching(account),
                .result(.failure([.offline("Offline"), .offline("Offline")]))
                ],
              isSearching: [
                false,
                true,
                false
                ],
              history: [
                [],
                [account]
            ])
    }

    func testErrorWithUserName() {
        let account = "error"
        check(account: account,
              accountResult: [
                .initialState,
                .searching(account),
                .result(.notFound)
                ],
              isSearching: [
                false,
                true,
                false
                ],
              history: [
                [],
                [account]
            ])
    }
}
