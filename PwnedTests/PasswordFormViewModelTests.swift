//
//  PasswordFormViewModelTests.swift
//  PwnedTests
//
//  Created by Kevin on 11/12/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import Pwned

class PasswordFormViewModelTests: XCTestCase {
    //var appServices: AppServices?

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFound() {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let dependencies = createServices()
        let viewModel = PasswordFormViewModel(dependencies: dependencies,
                                              scheduler: scheduler,
                                              searchScheduler: scheduler)
        let resultsObs = scheduler.createObserver(PasswordState.self)
        let isSearchingObs = scheduler.createObserver(Bool.self)

        viewModel.resultsObservable
            .asDriver(onErrorJustReturn: .initialState)
            .drive(resultsObs)
            .disposed(by: disposeBag)

        viewModel.isSearching
            .asDriver(onErrorJustReturn: false)
            .drive(isSearchingObs)
            .disposed(by: disposeBag)

        scheduler.createColdObservable([
                .next(10, "password")
            ])
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(
            resultsObs.events.map { $0.value.element },
            [
                .initialState,
                .searching("password"),
                .result(.success(3000000))
            ],
            "resultsObservable must emit the correct events!")

        XCTAssertEqual(
            isSearchingObs.events.map { $0.value.element },
            [
                false,
                true,
                false
            ],
            "isSearching must emit the correct events!")
    }
}
