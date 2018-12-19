//
//  AccountListViewController.swift
//  Pwned
//
//  Created by Kevin on 7/6/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxDataSources

enum AccountSectionItem: Equatable {
    case breach(Breach)
    case paste(Paste)
}

typealias AccountSection = AnimatableSectionModel<String, AccountSectionItem>

extension AccountSectionItem: IdentifiableType {
    public typealias Identity = String
    public var identity: Identity {
        switch self {
        case .breach(let breach):
            return breach.name
        case .paste(let paste):
            return paste.identifier
        }
    }
}

class AccountListViewController: UIViewController, StoryboardBased, ViewModelBased {
    typealias ViewModelType = AccountListViewModel
    var viewModel: AccountListViewModel!
    private let searchController = UISearchController(searchResultsController: nil)
    private let disposeBag = DisposeBag()
    private let dataSource = RxTableViewSectionedAnimatedDataSource<AccountSection>(
        configureCell: { (_, _, _, _) -> UITableViewCell in
            return UITableViewCell()
    })
    private lazy var itemSelectedObservable = {
        return tableView.rx.itemSelected.share()
    }()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noResultsView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private func configureDataSource() {
        dataSource.configureCell = {
            dataSource, tableView, indexPath, item in
            switch item {
            case .breach(let breach):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "BreachCell",
                    for: indexPath) as? BreachTableViewCell else {
                        return UITableViewCell()
                }
                cell.configure(breach: breach,
                               imageService: self.viewModel.dependencies.imageService)
                return cell
            case .paste(let paste):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "PasteCell",
                    for: indexPath) as? PasteTableViewCell else {
                        return UITableViewCell()
                }
                cell.configure(paste: paste)
                return cell
            }
        }
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource[index]
            let title = section.model
            return title
        }
        dataSource.canEditRowAtIndexPath = { _, _ in true }
    }

    private func configure(state: AccountState) {
        switch state {
        case .initialState:
            tableView.backgroundView = nil
            tableView.separatorStyle = .none
        case .searching:
            tableView.backgroundView = loadingView
            tableView.separatorStyle = .none
        case .result(let result):
            switch result {
            case .success:
                tableView.backgroundView = nil
                tableView.separatorStyle = .singleLine
            case .notFound, .failure:
                tableView.backgroundView = noResultsView
                tableView.separatorStyle = .none
            }
        }
    }

    private func bindViewModel() {
        // Inputs
        // Bind the activity indicator to the searching status.
        viewModel.isSearching
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        // Setup the state management so changes in state update the UI.
        viewModel.breachStateObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.configure(state: state)
            })
            .disposed(by: disposeBag)

        viewModel.breachObservable
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewModel.warningMessageObservable
            .drive(warningLabel.rx.text)
            .disposed(by: disposeBag)

        // Outputs
        itemSelectedObservable
            .map { [weak self] indexPath in
                guard let self = self else { return nil }
                guard let cell = self.tableView.cellForRow(
                    at: indexPath) as? BreachTableViewCell else {
                    return nil
                }
                return cell.breach
            }
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: viewModel.breachSelectedTrigger)
            .disposed(by: disposeBag)

        itemSelectedObservable
            .map { [weak self] indexPath in
                guard let self = self else { return nil }
                guard let cell = self.tableView.cellForRow(
                    at: indexPath) as? PasteTableViewCell else {
                        return nil
                }
                return cell.paste
            }
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: viewModel.pasteSelectedTrigger)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        bindViewModel()
        configure(state: .initialState)

        // Deselect a row whenever it is selected.
        itemSelectedObservable
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.tableView.deselectRow(at: indexPath, animated: false)
            })
            .disposed(by: disposeBag)
    }
}

extension AccountListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView(frame: .zero)
        view.contentView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        return view
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
}
