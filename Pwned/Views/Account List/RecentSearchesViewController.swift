//
//  RecentSearchesViewController.swift
//  Pwned
//
//  Created by Kevin on 11/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxDataSources

typealias HistorySection = AnimatableSectionModel<String, String>

class RecentSearchesViewController: UIViewController, StoryboardBased, ViewModelBased {
    typealias ViewModelType = RecentSearchesViewModel
    var viewModel: RecentSearchesViewModel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noRecentsView: UIView!
    @IBOutlet weak var noRecentsLabel: UILabel!

    private let bag = DisposeBag()
    private let dataSource = RxTableViewSectionedAnimatedDataSource<HistorySection>(
        configureCell: { (_, _, _, _) -> UITableViewCell in
            return UITableViewCell()
    })

    private func configureDataSource() {
        dataSource.configureCell = {
            dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "AccountHistoryCell",
                for: indexPath) as? AccountHistoryTableViewCell else {
                    return UITableViewCell()
            }
            cell.configure(item: item)
            return cell
        }
        dataSource.titleForHeaderInSection = {
            dataSource, index in
            return dataSource.sectionModels[index].model
        }
        dataSource.canEditRowAtIndexPath = { _, _ in true }
    }

    private func bindViewModel() {
        // Inputs
        viewModel.historyObservable
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        viewModel.historyObservable
            .subscribe(onNext: { [weak self] history in
                guard let self = self else { return }
                self.tableView.backgroundView =
                    !history.isEmpty ? nil : self.noRecentsView
            })
            .disposed(by: bag)

        // Ouputs
        tableView.rx
            .itemSelected
            .map { [weak self] indexPath in
                guard let self = self else { return nil }
                guard let cell = self.tableView.cellForRow(
                    at: indexPath) as? AccountHistoryTableViewCell,
                    let item = cell.titleLabel.text else { return nil }
                return item
            }
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: viewModel.itemSelectedTrigger)
            .disposed(by: disposeBag)
    }

    func reload() {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        bindViewModel()
    }
}

extension RecentSearchesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "AccountHistoryHeaderCell",
            for: IndexPath(row: 0, section: section)) as? AccountHistoryHeaderTableViewCell else {
                return nil
        }
        let title = dataSource.sectionModels[section].model
        cell.configure(title: title, model: viewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
