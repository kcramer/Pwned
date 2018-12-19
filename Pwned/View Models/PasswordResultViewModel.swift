//
//  PasswordResultViewModel.swift
//  Pwned
//
//  Created by Kevin on 11/4/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PasswordResultViewState {
    enum Color {
        case green
        case red
    }
    var imageName: String
    var countText: String
    var countColor: Color
    var showOccurrences: Bool
}

class PasswordResultViewModel: ViewModel {
    typealias Dependencies = HasReduxStore
    private let dependencies: Dependencies
    private var mainStore: ReduxStore {
        return dependencies.mainStore
    }
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter
    }()

    lazy var resultsObservable: Observable<PasswordState> = {
        return mainStore
            .observable
            .observeOn(MainScheduler.instance)
            .map { $0.passwordResult }
            .distinctUntilChanged()
            .catchErrorJustReturn(.initialState)
            .share(replay: 1, scope: .whileConnected)
    }()

    lazy var viewStateObservable: Observable<PasswordResultViewState> = {
        return resultsObservable
            .map { state -> PasswordResultViewState? in
                guard case .result(let result) = state else { return nil }
                switch result {
                case .success(let count):
                    if count > 0 {
                        return PasswordResultViewState(
                            imageName: "Bad Icon",
                            countText: self.format(count: count) ?? "",
                            countColor: .red,
                            showOccurrences: true)
                    } else {
                        return PasswordResultViewState(
                            imageName: "Good Icon",
                            countText: "Safe",
                            countColor: .green,
                            showOccurrences: false)
                    }
                case .failure:
                    return PasswordResultViewState(
                        imageName: "",
                        countText: "Error",
                        countColor: .red,
                        showOccurrences: false)
                }
            }
            .filter { $0 != nil }
            .map { $0! }
    }()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func format(count: Int) -> String? {
        return formatter.string(from: NSNumber(value: count))
    }
}
