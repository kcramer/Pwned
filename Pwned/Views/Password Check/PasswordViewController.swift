//
//  PasswordViewController.swift
//  Pwned
//
//  Created by Kevin on 11/4/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import RxSwift

class PasswordViewController: UIViewController {
    private let formVC: PasswordFormViewController
    private let resultVC: PasswordResultViewController
    private let viewModel: PasswordFormViewModel
    private let disposeBag = DisposeBag()
    private let searchController = UISearchController(searchResultsController: nil)

    init(form: PasswordFormViewController,
         result: PasswordResultViewController,
         viewModel: PasswordFormViewModel) {
        formVC = form
        resultVC = result
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
            "PasswordPlaceholder", comment: "Passwor Field Placeholder Text")
        searchController.searchBar.isSecureTextEntry = true
        searchController.searchBar.keyboardType = .default
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.keyboardAppearance = .dark

        navigationController?.navigationBar.prefersLargeTitles = true

        let navigationItem = self.navigationItem
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func bindViewModel() {
        // Inputs
        viewModel
            .resultsObservable
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { result in
                switch result {
                case .result:
                    self.transitionToResult()
                default:
                    self.transitionToForm()
                }
            })
            .disposed(by: disposeBag)

        // Outputs
        let passwordObservable = searchController.searchBar.rx.text.orEmpty
        let searchClicked = searchController.searchBar.rx.searchButtonClicked
        let cancelClicked = searchController.searchBar.rx.cancelButtonClicked.asDriver()

        // On Cancel, clear the password in the view model.
        cancelClicked
            .map { "" }
            .drive(viewModel.password)
            .disposed(by: disposeBag)

        // For a search, get the password field, and update the view model.
        Observable.of(searchClicked)
            .merge()
            .withLatestFrom(passwordObservable)
            .asDriver(onErrorJustReturn: "")
            .filter { !$0.isEmpty }
            .drive(viewModel.password)
            .disposed(by: disposeBag)

        // If the field is cleared, push to reset state.
        passwordObservable
            .filter { $0.isEmpty }
            .asDriver(onErrorJustReturn: "")
            .drive(viewModel.password)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        add(asChild: resultVC)
        add(asChild: formVC)
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

    private func transitionToForm() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveEaseOut, .transitionCrossDissolve],
                       animations: {
                        self.resultVC.view.alpha = 0
                        self.formVC.view.alpha = 1
        })
    }

    private func transitionToResult() {
        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       options: [.curveEaseOut, .transitionCrossDissolve],
                       animations: {
                        self.formVC.view.alpha = 0
                        self.resultVC.view.alpha = 1
        })
    }
}
