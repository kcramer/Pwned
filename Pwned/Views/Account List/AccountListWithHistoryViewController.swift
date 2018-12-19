//
//  AccountListWithHistoryViewController.swift
//  Pwned
//
//  Created by Kevin on 11/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import RxSwift

class AccountListWithHistoryViewController: UIViewController {
    private let accountListVC: AccountListViewController
    private let historyVC: RecentSearchesViewController
    private let viewModel: AccountListViewModel
    private let disposeBag = DisposeBag()

    private let searchController = UISearchController(searchResultsController: nil)

    init(accountList: AccountListViewController,
         history: RecentSearchesViewController,
         viewModel: AccountListViewModel) {
        accountListVC = accountList
        historyVC = history
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        self.definesPresentationContext = true

        searchController.definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString(
            "BreachSearchPlaceholder", comment: "Breach Search Field Placeholder Text")
        searchController.searchBar.keyboardType = .emailAddress
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.keyboardAppearance = .dark

        navigationController?.navigationBar.prefersLargeTitles = true

        let navigationItem = self.navigationItem
        navigationItem.title = NSLocalizedString("Account Search", comment: "Title for screen.")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func bindViewModel() {
        // Inputs
        // Set the search field text to the search term.
        viewModel.breachStateObservable
            .subscribe(onNext: { state in
                if case .searching(let account) = state {
                    self.searchController.searchBar.text = account
                    self.searchController.searchBar.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)

        viewModel
            .breachStateObservable
            .subscribe(onNext: { result in
                switch result {
                case .searching, .result:
                    self.transitionToAccountList()
                default:
                    self.transitionToHistory()
                }
            })
            .disposed(by: disposeBag)

        // Outputs
        let accountObservable = searchController.searchBar.rx.text.orEmpty
        let searchClicked = searchController.searchBar.rx.searchButtonClicked
        let cancelClicked = searchController.searchBar.rx.cancelButtonClicked.asDriver()

        // On Cancel, clear the account in the view model.
        cancelClicked
            .map { "" }
            .drive(viewModel.account)
            .disposed(by: disposeBag)

        // For a search, get the account field, and update the view model.
        Observable.of(searchClicked)
            .merge()
            .withLatestFrom(accountObservable)
            .asDriver(onErrorJustReturn: "")
            .drive(viewModel.account)
            .disposed(by: disposeBag)

        // If the field is cleared, push to reset state.
        accountObservable
            .filter { $0.isEmpty }
            .asDriver(onErrorJustReturn: "")
            .drive(viewModel.account)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        add(asChild: historyVC)
        add(asChild: accountListVC)

        configure()
        bindViewModel()
    }

    private func add(asChild controller: UIViewController) {
        addChild(controller)
        guard let childView = controller.view else { return }
        view.addSubview(childView)
        childView.frame = view.bounds
        childView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.didMove(toParent: self)
    }

    private func transitionToHistory() {
        self.accountListVC.view.alpha = 0
        self.historyVC.view.alpha = 1
        self.historyVC.reload()
    }

    private func transitionToAccountList() {
        self.historyVC.view.alpha = 0
        self.accountListVC.view.alpha = 1
    }
}
